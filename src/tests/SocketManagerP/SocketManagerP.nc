#include "Socket.h"
#include <string.h>
#include "TestCase.h"

generic module SocketManagerP(uint8_t socket_count) {
  provides interface ISocket[uint8_t id];

  uses {
    //interface Boot; // use Init / StdControl / SplitControl
    interface Receive;
    interface AMSend;
    interface Packet;
  }
}
implementation {

  socket_t sockets[socket_count];
  port_t ports[socket_count];

  message_t packet;
  bool locked;

  event void AMSend.sendDone(message_t * msg, error_t error) {
    if(&packet == msg) {
      socket_msg_t * smsg = (socket_msg_t * ) call Packet.getPayload(&packet,
					sizeof(socket_msg_t));
      uint8_t port_nr = smsg->port_nr;
      uint8_t socket_nr = ports[port_nr - 1].socket_nr;
      signal ISocket.sendDone[socket_nr](SOCKET_SUCCESS);
      locked = FALSE;
    }
    else {
      // TODO
    }
  }

  event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
    if(len != sizeof(socket_msg_t)) {
      return msg;
    }
    else {
      socket_msg_t * smsg = (socket_msg_t * ) payload;
      uint8_t socket_nr;
      uint8_t port_nr = smsg->port_nr;
      if(port_nr <= 0 || port_nr > socket_count) 
        return msg;
      socket_nr = ports[port_nr - 1].socket_nr;
      if(sockets[socket_nr].buf_ptr == NULL) {
        dbg("MySocketApp",
						"[SocketManagerM] (Receive.receive) Message IGNORED (socket %hhu, port %hhu).\n", socket_nr, port_nr);
        return msg;
      }
      else {
        memcpy(sockets[socket_nr].buf_ptr, smsg->buf, sockets[socket_nr]
						.buf_len);
        dbg("MySocketApp", "[SocketManagerM] (Receive.receive) '%s' (%hhu).\n",
						sockets[socket_nr].buf_ptr, sockets[socket_nr].buf_len);
        signal ISocket.receiveDone[socket_nr](SOCKET_SUCCESS);
      }
      return msg;
    }
  }

  command uint8_t ISocket.bind[uint8_t id](uint8_t port_nr) {
    uint8_t i;
    if(port_nr > socket_count) {
      dbg("MySocketApp",
					"[SocketManagerM] (ISocket.bind) INVALID PORT NUMBER id: %hhu -> port: %hhu.\n", id, port_nr);
      return SOCKET_ERROR;
    }
    else 
      if(port_nr == 0) {
      for(i = 0; i < socket_count; ++i) {
        if( ! ports[i].in_use) {
          port_nr = i + 1;
          break;
        }
      }
    }
    else 
      if(ports[port_nr - 1].socket_nr > 0) {
      dbg("MySocketApp",
					"[SocketManagerM] (ISocket.bind) PORT ALREADY IN USE id: %hhu -> port: %hhu.\n", id, port_nr);
      return SOCKET_IN_USE;
    }

    sockets[id].port_nr = port_nr;
    ports[port_nr - 1].socket_nr = id;
    ports[port_nr - 1].in_use = 1;
    dbg("MySocketApp",
				"[SocketManagerM] (ISocket.bind) END id: %hhu -> port: %hhu.\n", id,
				port_nr);
    return SOCKET_SUCCESS;
  }

  command uint8_t ISocket.getPort[uint8_t id]() {
    return sockets[id].port_nr;
  }

  command uint8_t ISocket.receive[uint8_t id](char * buf, uint8_t len) {
    sockets[id].buf_ptr = buf;
    sockets[id].buf_len = len;
    return SOCKET_SUCCESS;
  }

  command uint8_t ISocket.send[uint8_t id](char * buf, uint8_t len) {
    dbg("MySocketApp", "[SocketManagerM] (send) id = %hhu.\n", id);
    if(locked) {
      dbg("MySocketApp", "[SocketManagerM] (send) LOCKED id = %hhu.\n", id);
      return SOCKET_ERROR;
    }
    else {
      socket_msg_t * smsg = (socket_msg_t * ) call Packet.getPayload(&packet,
					sizeof(socket_msg_t));
      if(smsg == NULL) {
        dbg("MySocketApp", "[SocketManagerM] (send) NULL id = %hhu.\n", id);
        return SOCKET_ERROR;
      }
      smsg->port_nr = sockets[id].port_nr;
      memcpy(smsg->buf, buf, len);
      smsg->len = len;
      if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(socket_msg_t)) == SUCCESS) {
        dbg("MySocketApp", "[SocketManagerM] (send) Packet sent. id = %hhu, text: %s (%hhu).\n",
						id, smsg->buf, smsg->len);
        locked = TRUE;
      }
      else {
        dbg("MySocketApp",
						"[SocketManagerM] (send) Packet not sent. id = %hhu.\n", id);
      }
    }
    return 0;
  }

  default event void ISocket.receiveDone[uint8_t id](socket_err_t err) {
    dbg("MySocketApp", "[SocketManagerM] (receiveDone) Invalid ID = %hhu.\n",
				id);
  }

  default event void ISocket.sendDone[uint8_t id](socket_err_t err) {
    dbg("MySocketApp", "[SocketManagerM] (sendDone) Invalid ID = %hhu.\n", id);
  }

}
