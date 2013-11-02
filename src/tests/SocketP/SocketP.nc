#include "Socket.h"

generic module SocketP(uint8_t id) {

  provides interface ISocket;

  uses {
    interface ISocket as ManagerSocket;
    interface Boot;
    interface Timer<TMilli> as Timer;
  }

}
implementation {

  bool wait;
  message_t packet;
  bool locked;

  event void Boot.booted() {
    //dbg("Boot", "[SocketM] (booted) ID = %hhu.\n", id);
  }

  event void Timer.fired() {
    if(wait) {
      //dbg("MySocketApp", "[SocketM] (fired) TIMEOUT ID = %hhu.\n", id);
      wait = FALSE;
      call ManagerSocket.receive(NULL, 0);
      signal ISocket.receiveDone(SOCKET_ETIMEOUT);
    }
  }

  command uint8_t ISocket.send(char* buf, uint8_t len) {
    return call ManagerSocket.send(buf, len);
  }

  command uint8_t ISocket.receive(char* buf, uint8_t len) {
    dbg("MySocketApp", "[SocketM] (receive) ID = %hhu.\n", id);
    wait = TRUE;
    call Timer.startOneShot(TIMEOUT);
    return call ManagerSocket.receive(buf, len);
  }

  command uint8_t ISocket.getPort() {
    return call ManagerSocket.getPort();
  }

  command uint8_t ISocket.bind(uint8_t port_nr) {
    return call ManagerSocket.bind(port_nr);
  }

  event void ManagerSocket.receiveDone(socket_err_t err) {
    if(wait) {
      wait = FALSE;
      call Timer.stop();
      dbg("MySocketApp", "[SocketM] (receiveDone) OK ID = %hhu.\n", id);
      signal ISocket.receiveDone(err);
    } else {
      dbg("MySocketApp", "[SocketM] (receiveDone) IGNORED ID = %hhu.\n", id);
    }
  }

  event void ManagerSocket.sendDone(socket_err_t err) {
    //dbg("MySocketApp", "[SocketM] (sendDone) ID = %hhu.\n", id);
    signal ISocket.sendDone(err);
  }
}