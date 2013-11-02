#include "Socket.h"

generic configuration MockSocketC() {
  provides interface ISocket;
}
implementation {

  enum {
    ID = unique(UNIQUE_SOCKET),
  };

  components new MockSocketP(ID);
  components SocketManagerC as SM;

  ISocket = MockSocketP.ISocket;
  MockSocketP.ManagerSocket->SM.ISocket[ID];
}
