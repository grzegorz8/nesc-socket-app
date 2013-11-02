#include "Socket.h"
#include "Test.h"
#include "TestCase.h"

generic module MockAMSenderP(uint8_t id) {
  provides {
    interface Mock;
    interface AMSend;
    interface Packet;
  }
}

implementation {

  void * packet;
  
  uint8_t call_count = 0;

  command void Mock.fireEvent(uint8_t action_id) {
    call_count ++;
    assertEquals("", 1, call_count);
    signal AMSend.sendDone(packet, action_id);
  }

  command error_t AMSend.send(am_addr_t addr, message_t* msg, uint8_t len) {
    return 0;
  }

  command error_t AMSend.cancel(message_t* msg) {
    return 0;
  }

  command uint8_t AMSend.maxPayloadLength() {
    return 0;
  }

  command void* AMSend.getPayload(message_t* msg, uint8_t len) {
    return NULL;
  }

  command void Packet.clear(message_t* msg) {
  }

  command uint8_t Packet.payloadLength(message_t* msg) {
    return 0;
  }

  command void Packet.setPayloadLength(message_t* msg, uint8_t len) {
  }

  command uint8_t Packet.maxPayloadLength() {
    return 0;
  }

  command void* Packet.getPayload(message_t* msg, uint8_t len) {
    packet = msg;
    return (void *)msg;
  }

}
