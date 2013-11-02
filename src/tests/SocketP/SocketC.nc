#include "Socket.h"

generic configuration SocketC() {
  provides interface ISocket;
}
implementation {

  enum {
    ID = unique(UNIQUE_SOCKET),
  };

  components MainC;
  components new SocketP(ID);
  components new TimerMilliC();

  components MockSocketManagerC as SM;

  ISocket = SocketP.ISocket;

  SocketP.Boot->MainC.Boot;
  SocketP.Timer->TimerMilliC;

  SocketP.ManagerSocket->SM.ISocket[ID];
}
