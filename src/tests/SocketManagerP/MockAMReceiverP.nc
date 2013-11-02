#include "Socket.h"
#include "Test.h"
#include "TestCase.h"

generic module MockAMReceiverP(uint8_t id) {
  provides {
    interface Mock;
    interface Receive;
  }
}

implementation {
  socket_msg_t msg;
  char * text = RECEIVE_MSG;
  uint8_t call_count = 0;

  command void Mock.fireEvent(uint8_t action_id) {
    call_count ++;
    assertResultIsBelow("", 3, call_count);
    msg.port_nr = action_id;
    msg.len = RECEIVE_MSG_LEN;
    memcpy(msg.buf, text, msg.len);
    signal Receive.receive(NULL, &msg, sizeof(socket_msg_t));
  }
}
