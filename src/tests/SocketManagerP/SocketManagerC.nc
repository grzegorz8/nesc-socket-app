#include "Socket.h"

configuration SocketManagerC {
  provides interface ISocket[uint8_t id];
  provides interface Mock as Receiver;
  provides interface Mock as Sender;
}
implementation {
  enum {
    SOCKET_COUNT = uniqueCount(UNIQUE_SOCKET)
  };

  components new SocketManagerP(SOCKET_COUNT);
  components new MockAMSenderP(6);
  components new MockAMReceiverP(6);

  SocketManagerP.Receive->MockAMReceiverP;
  SocketManagerP.AMSend->MockAMSenderP;
  SocketManagerP.Packet->MockAMSenderP;
  
  MockAMReceiverP.Mock = Receiver;
  MockAMSenderP.Mock = Sender;

  ISocket = SocketManagerP.ISocket;
}
