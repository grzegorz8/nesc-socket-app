#include "Socket.h"
#include "Test.h"
#include "TestCase.h"
#include <string.h>

generic module MockSocketManagerP(uint8_t socket_count) {
  provides interface ISocket[uint8_t id];

  uses {
    //interface Boot; // use Init / StdControl / SplitControl
    interface Receive;
    interface AMSend;
    interface Packet;
    interface Timer<TMilli> as Timer;
  }
}
implementation {

  enum {
    S_IDLE = 0,
    S_RECEIVE = 1,
    S_RECEIVE_TIMEOUT = 2,
    S_SEND = 3,
  };
  
  uint8_t state = S_IDLE;

  uint8_t bind_call = 0;
  uint8_t getPort_call = 0;
  uint8_t send_call = 0;
  uint8_t receive_call = 0;  
  
  uint8_t socket_id = 0;
  
  event void Timer.fired() {
    if (state == S_SEND) {
      signal ISocket.sendDone[socket_id](SOCKET_SUCCESS);
    } else if (state == S_RECEIVE) {
      signal ISocket.receiveDone[socket_id](SOCKET_SUCCESS);
    } else if (state == S_RECEIVE_TIMEOUT) {
      signal ISocket.receiveDone[socket_id](SOCKET_SUCCESS);
    } else {
      assertFail("Unhandled fired event.");
    }
  }

  event void AMSend.sendDone(message_t * msg, error_t error) {
  }

  event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
    return msg;
  }

  command uint8_t ISocket.bind[uint8_t id](uint8_t port_nr) {
    bind_call ++;
    assertEquals("bind called more than once", 1, bind_call);
    return SOCKET_SUCCESS;
  }

  command uint8_t ISocket.getPort[uint8_t id]() {
    getPort_call ++;
    assertEquals("getPort called more than once", 1, getPort_call);
    return GET_PORT_TEST_VALUE;
  }

  command uint8_t ISocket.receive[uint8_t id](char * buf, uint8_t len) {
    receive_call ++;
    assertResultIsBelow("send called more than twice", 4, receive_call);
    // Jedno wolanie jest jest zuzywane gdy po TIMEOUT trzeba wynullowac
    // przeslane wskazniki.
    socket_id = id;
    if (receive_call == 1) {
      state = S_RECEIVE;
      call Timer.startOneShot(100);
    } else if (receive_call == 2) {
      state = S_RECEIVE_TIMEOUT;
      call Timer.startOneShot(TIMEOUT + 100);
    } else if (receive_call == 3) {
      assertNull(buf);
      assertEquals("", 0, len);
    } else {
      assertFail("Unhandled receive call.");
    }
    return SOCKET_SUCCESS;
  }

  command uint8_t ISocket.send[uint8_t id](char * buf, uint8_t len) {
    send_call ++;
    assertEquals("send called more than once", 1, send_call);
    socket_id = id;
    state = S_SEND;
    call Timer.startOneShot(100);
    return SOCKET_SUCCESS;
  }

  default event void ISocket.receiveDone[uint8_t id](socket_err_t err) {
    assertFail("Default receiveDone event signaled.\n");
  }

  default event void ISocket.sendDone[uint8_t id](socket_err_t err) {
    assertFail("Default sendDone event signaled.\n");
  }

}
