#include "Socket.h"
#include "Test.h"
#include "TestCase.h"

generic module MockSocketP(uint8_t id) {

  provides interface ISocket;

  uses {
    interface ISocket as ManagerSocket;
  }

}
implementation {

  command uint8_t ISocket.send(char* buf, uint8_t len) {
    return call ManagerSocket.send(buf, len);
  }

  command uint8_t ISocket.receive(char* buf, uint8_t len) {
    return call ManagerSocket.receive(buf, len);
  }

  command uint8_t ISocket.getPort() {
    return call ManagerSocket.getPort();
  }

  command uint8_t ISocket.bind(uint8_t port_nr) {
    return call ManagerSocket.bind(port_nr);
  }

  event void ManagerSocket.receiveDone(socket_err_t err) {
    signal ISocket.receiveDone(err);
  }

  event void ManagerSocket.sendDone(socket_err_t err) {
    signal ISocket.sendDone(err);
  }
}
