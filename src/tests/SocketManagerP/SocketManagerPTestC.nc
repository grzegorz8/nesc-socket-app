#include"Socket.h"

configuration SocketManagerPTestC {
}
implementation {

  enum {
    SOCKET_COUNT = uniqueCount(UNIQUE_SOCKET)
  };

  components SocketManagerC as SM;

  components new MockSocketC() as S1;
  components new MockSocketC() as S2;
  components new MockSocketC() as S3;
  
  components new TimerMilliC() as Timer;
  
  components SocketManagerPTestP;
  SocketManagerPTestP.Timer->Timer;
  
  SocketManagerPTestP.Receiver->SM.Receiver;
  SocketManagerPTestP.Sender->SM.Sender;
  
  components new TestCaseC() as UnexpectedMessageTestC;
  components new TestCaseC() as BindPortTestC;
  components new TestCaseC() as ReceiveMessageTestC;
  components new TestCaseC() as SendMessageTestC;
  
  SocketManagerPTestP.Socket1->S1.ISocket;
  SocketManagerPTestP.Socket2->S2.ISocket;
  SocketManagerPTestP.Socket3->S3.ISocket;
  
  SocketManagerPTestP.UnexpectedMessageTest->UnexpectedMessageTestC;
  SocketManagerPTestP.BindPortTest->BindPortTestC;
  SocketManagerPTestP.ReceiveMessageTest->ReceiveMessageTestC;
  SocketManagerPTestP.SendMessageTest->SendMessageTestC;
}
