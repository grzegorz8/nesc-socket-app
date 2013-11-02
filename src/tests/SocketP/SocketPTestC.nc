configuration SocketPTestC {
} 
implementation {
     
  components MockSocketManagerC as SM;
  components new SocketC() as S1;
  components new SocketC() as S2;
  components new SocketC() as S3;
  
  components SocketPTestP;
  
  components new TestCaseC() as BindPortTestC;   
  components new TestCaseC() as GetPortTestC;
  components new TestCaseC() as SendMessageTestC;
  components new TestCaseC() as ReceiveMessageTestC;
  components new TestCaseC() as ReceiveMessageTimeoutTestC;
  
  SocketPTestP.Socket1->S1.ISocket;
  SocketPTestP.Socket2->S2.ISocket;
  SocketPTestP.Socket3->S3.ISocket;
  
  SocketPTestP.BindPortTest -> BindPortTestC;
  SocketPTestP.GetPortTest -> GetPortTestC;
  SocketPTestP.SendMessageTest -> SendMessageTestC;
  SocketPTestP.ReceiveMessageTest -> ReceiveMessageTestC;
  SocketPTestP.ReceiveMessageTimeoutTest -> ReceiveMessageTimeoutTestC;
}
