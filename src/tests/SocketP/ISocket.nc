#include"Socket.h"

interface ISocket {
  command uint8_t send(char* buf, uint8_t len);
  event void sendDone(socket_err_t err);
  command uint8_t receive(char* buf, uint8_t len);
  event void receiveDone(socket_err_t err);
  command uint8_t getPort();
  command uint8_t bind(uint8_t port_nr);
}