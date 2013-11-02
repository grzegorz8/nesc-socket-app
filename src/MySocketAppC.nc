#include"Socket.h"

configuration MySocketAppC {
}
implementation {
  components MainC, MySocketC as App;
  components new TimerMilliC();
  components ActiveMessageC;
  components new SocketC() as S1;
  components new SocketC() as S2;
  components new SocketC() as S3;


  App.Boot->MainC.Boot;
  App.AMControl->ActiveMessageC;
  
  App.Socket1->S1.ISocket;
  App.Socket2->S2.ISocket;
  App.Socket3->S3.ISocket;
  
  App.MilliTimer->TimerMilliC;
}
