#include "Socket.h"
#include "Timer.h"

module MySocketC {

  uses {
    interface Timer<TMilli> as MilliTimer;
    interface Boot;
    interface SplitControl as AMControl;
    interface ISocket as Socket1;
    interface ISocket as Socket2;
    interface ISocket as Socket3;
  }
}
implementation {

  uint8_t i;
  char text1[BUF_LEN];
  char text2[BUF_LEN];
  char text3[BUF_LEN];

  event void MilliTimer.fired() {
    if(i % 6 == 1) {
      call Socket1.send("Ala ma kota.", 12);
    }
    else 
      if(i % 6 == 0) {
      call Socket1.receive(text1, 12);
    }
    else 
      if(i % 6 == 3) {
      call Socket2.send("Hello world!!!", 14);
    }
    else 
      if(i % 6 == 2) {
      call Socket2.receive(text2, 14);
    }
    //else 
    //  if(i % 6 == 5) {
    //  call Socket3.send();
    //}
    else 
      if(i % 6 == 4) {
      call Socket3.receive(text3, 10);
    }
    i++;
    if(i >= 6) 
      call MilliTimer.stop();
  }

  event void Boot.booted() {
    dbg("MySocketApp", "[MySocketC] (booted).\n");
    call AMControl.start();
  }

  event void AMControl.startDone(error_t error) {
    if(error == SUCCESS) {
      call Socket1.bind(0);
      call Socket2.bind(3);
      call Socket3.bind(0);
      call MilliTimer.startPeriodic(300);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t error) {
    // TODO nothing to do.
  }

  event void Socket1.sendDone(socket_err_t err) {
    dbg("MySocketApp", "[MySocketC] (sendDone) id: %hhu, code: %hhu.\n", 0,
				err);
  }

  event void Socket1.receiveDone(socket_err_t err) {
    if(err == SOCKET_SUCCESS) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) OK id: %hhu, text: '%s'.\n",
					0, text1);
    else 
      if(err == SOCKET_ETIMEOUT) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) TIMEOUT id: %hhu.\n", 0);
  }

  event void Socket2.sendDone(socket_err_t err) {
    dbg("MySocketApp", "[MySocketC] (sendDone) id: %hhu, code: %hhu.\n", 1,
				err);
  }

  event void Socket2.receiveDone(socket_err_t err) {
    if(err == SOCKET_SUCCESS) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) OK id: %hhu, text: '%s'.\n",
					1, text2);
    else 
      if(err == SOCKET_ETIMEOUT) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) TIMEOUT id: %hhu.\n", 1);
  }

  event void Socket3.sendDone(socket_err_t err) {
    dbg("MySocketApp", "[MySocketC] (sendDone) id: %hhu, code: %hhu.\n", 2,
				err);
  }

  event void Socket3.receiveDone(socket_err_t err) {
    if(err == SOCKET_SUCCESS) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) OK id: %hhu, text: '%s'.\n",
					2, text3);
    else 
      if(err == SOCKET_ETIMEOUT) 
      dbg("MySocketApp", "[MySocketC] (receiveDone) TIMEOUT id: %hhu.\n", 2);
  }

}