#include "Socket.h"

configuration MockSocketManagerC {
  provides interface ISocket[uint8_t id];
}
implementation {
  enum {
    SOCKET_COUNT = uniqueCount(UNIQUE_SOCKET)
  };

  components new MockSocketManagerP(SOCKET_COUNT);
  components new AMSenderC(6);
  components new AMReceiverC(6);
  components ActiveMessageC;
  components new TimerMilliC() as Timer;

  MockSocketManagerP.Receive->AMReceiverC;
  MockSocketManagerP.AMSend->AMSenderC;
  MockSocketManagerP.Packet->AMSenderC;
  MockSocketManagerP.Timer->Timer;

  ISocket = MockSocketManagerP.ISocket;
}
