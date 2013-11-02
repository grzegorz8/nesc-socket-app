#include "Socket.h"
#include "Timer.h"
#include "Test.h"
#include "TestCase.h"
#include <string.h>

module SocketManagerPTestP {
  uses {
    interface Timer<TMilli> as Timer;
  
    interface ISocket as Socket1;
    interface ISocket as Socket2;
    interface ISocket as Socket3;
    
    interface Mock as Receiver;
    interface Mock as Sender;
    
    interface TestCase as UnexpectedMessageTest;
    interface TestCase as BindPortTest;
    interface TestCase as ReceiveMessageTest;
    interface TestCase as SendMessageTest;
  }
}
     
implementation {

  uint8_t unexp_mes_count = 0;
  char text[BUF_LEN];
  
  enum {
    S_IDLE = 0,
    S_UNEXPECTED_MESSAGE = 1,
    S_BIND = 2,
    S_RECEIVE_MESSAGE = 3,
    S_SEND_MESSAGE = 4,
  };
  
  uint8_t state = S_IDLE;
  
  event void UnexpectedMessageTest.run() {
    state = S_UNEXPECTED_MESSAGE; 
    call Timer.startOneShot(500);
    call Receiver.fireEvent(1);
  }
  
  event void BindPortTest.run() {
    state = S_BIND;
    assertEquals("", SOCKET_SUCCESS, call Socket1.bind(1));
    assertEquals("", SOCKET_IN_USE, call Socket2.bind(1)); // FIXME 
    assertEquals("", SOCKET_IN_USE, call Socket2.bind(2)); // FIXME
    assertEquals("", SOCKET_ERROR, call Socket3.bind(15));
    assertEquals("", SOCKET_ERROR, call Socket3.bind(-15));
    assertEquals("", SOCKET_SUCCESS, call Socket3.bind(3));
    
    assertEquals("", 1, call Socket1.getPort());
    assertEquals("", 2, call Socket2.getPort());
    assertEquals("", 3, call Socket3.getPort());
    call BindPortTest.done();
  }
  
  event void ReceiveMessageTest.run() {
    state = S_RECEIVE_MESSAGE;
    call Socket2.receive(text, RECEIVE_MSG_LEN);
    call Receiver.fireEvent(2);
  }
  
  event void SendMessageTest.run() {
    state = S_SEND_MESSAGE;
    call Socket3.send(RECEIVE_MSG, RECEIVE_MSG_LEN);
    call Timer.startOneShot(200);
  }
  
  event void Timer.fired() {
    if (state == S_UNEXPECTED_MESSAGE) {
      assertEquals("", 0, unexp_mes_count);
      call UnexpectedMessageTest.done();
    } else if (state == S_SEND_MESSAGE) {
      call Sender.fireEvent(SOCKET_SUCCESS);
    } else {
      assertFail("Unhandled timer.fired");
    }
  }
  
  event void Socket1.sendDone(socket_err_t err) {
    if (state == S_SEND_MESSAGE) {
      assertTrue("Should not be signaled!", FALSE);
      call UnexpectedMessageTest.done();
    } else {
      assertFail("Unhandled socket2.sendDone");
    }
  }

  event void Socket1.receiveDone(socket_err_t err) {
    if (state == S_UNEXPECTED_MESSAGE) {
      atomic { unexp_mes_count ++; }
    } else if (state == S_RECEIVE_MESSAGE) {
      assertTrue("Socket3 should not receive this message.", FALSE);
      call ReceiveMessageTest.done(); 
    } else {
      assertFail("Unhandled Socket1.receiveDone");
    }
  }

  event void Socket2.sendDone(socket_err_t err) {
    if (state == S_SEND_MESSAGE) {
      assertTrue("Should not be signaled!", FALSE);
      call UnexpectedMessageTest.done();
    } else {
      assertFail("Unhandled socket2.sendDone");
    }
  }

  event void Socket2.receiveDone(socket_err_t err) {
    if (state == S_UNEXPECTED_MESSAGE) {
      atomic { unexp_mes_count ++; }
    } else if (state == S_RECEIVE_MESSAGE) {
      assertEquals("", SOCKET_SUCCESS, err);
      assertEquals("", 0, strncmp(text, RECEIVE_MSG, RECEIVE_MSG_LEN));
      call ReceiveMessageTest.done();
    } else {
      assertFail("Unhandled Socket2.receiveDone");
    }
  }

  event void Socket3.sendDone(socket_err_t err) {
  if (state == S_SEND_MESSAGE) {
      assertEquals("", SOCKET_SUCCESS, err);
      call UnexpectedMessageTest.done();
    } else {
      assertFail("Unhandled socket3.sendDone");
    }
  }

  event void Socket3.receiveDone(socket_err_t err) {
    if (state == S_UNEXPECTED_MESSAGE) {
      atomic { unexp_mes_count ++; }
    } else if (state == S_RECEIVE_MESSAGE) {
      assertTrue("Socket3 should not receive this message.", FALSE);
      call ReceiveMessageTest.done();
    }
    else {
      assertFail("Unhandled Socket3.receiveDone");
    }
  }
}
