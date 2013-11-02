#include "Socket.h"

configuration SocketManagerC {
  provides interface ISocket[uint8_t id];
}
implementation {
  enum {
    SOCKET_COUNT = uniqueCount(UNIQUE_SOCKET)
  };

  components new SocketManagerP(SOCKET_COUNT);
  components new AMSenderC(6);
  components new AMReceiverC(6);
  components ActiveMessageC;

  SocketManagerP.Receive->AMReceiverC;
  SocketManagerP.AMSend->AMSenderC;
  SocketManagerP.Packet->AMSenderC;

  ISocket = SocketManagerP.ISocket;
}
