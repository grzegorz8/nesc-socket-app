#include "TestCase.h"
#include "Test.h"
#include "Socket.h"
   
module SocketPTestP {
  uses {
    interface ISocket as Socket1;
    interface ISocket as Socket2;
    interface ISocket as Socket3;
    
    interface TestCase as BindPortTest;
    interface TestCase as GetPortTest;
    interface TestCase as SendMessageTest;
    interface TestCase as ReceiveMessageTest;
    interface TestCase as ReceiveMessageTimeoutTest;
  }
}
     
implementation {

  char msg[28];
  uint8_t data_len;
 
  event void BindPortTest.run() {
    if (call Socket3.bind(BIND_TEST_VALUE) != SOCKET_SUCCESS) {
      assertFail("Socket bind failure.\n");
    } else {
      assertSuccess();
    }
    call BindPortTest.done();
  }
  
  event void GetPortTest.run() {
    uint8_t port = call Socket3.getPort();
    assertEquals("Incorrect port number", GET_PORT_TEST_VALUE, port);
    call GetPortTest.done();
  }
  
  event void SendMessageTest.run() {
    if (call Socket3.send(msg, data_len) != SOCKET_SUCCESS) {
      assertFail("Failed to send");
      call SendMessageTest.done();
    }
  }
  
  event void ReceiveMessageTest.run() {
    if (call Socket2.receive(msg, data_len) != SOCKET_SUCCESS) {
      assertFail("Failed to receive");
      call ReceiveMessageTest.done();
    }
  }
  
  event void ReceiveMessageTimeoutTest.run() {
    if (call Socket1.receive(msg, data_len) != SOCKET_SUCCESS) {
      assertFail("Failed to receive timeout");
      call ReceiveMessageTimeoutTest.done();
    }
  }
  
  event void Socket1.sendDone(socket_err_t err) {
  }

  event void Socket1.receiveDone(socket_err_t err) {
    assertEquals("Receive failed", SOCKET_ETIMEOUT, err);
    call ReceiveMessageTimeoutTest.done();
  }

  event void Socket2.sendDone(socket_err_t err) {
  }

  event void Socket2.receiveDone(socket_err_t err) {
    assertEquals("Receive failed", SOCKET_SUCCESS, err);
    // TODO check msg
    call ReceiveMessageTest.done();
  }

  event void Socket3.sendDone(socket_err_t err) {
    assertEquals("Unexpected result", SOCKET_SUCCESS, err);
    call SendMessageTest.done();
  }

  event void Socket3.receiveDone(socket_err_t err) {

  }
    
}
