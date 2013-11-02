#ifndef SOCKET_H
#define SOCKET_H

#define UNIQUE_SOCKET "Socket"
#define UNIQUE_TIMER "Timer"
#define TIMEOUT 1000
#define BUF_LEN 26

typedef struct socket {
  uint8_t port_nr;
  char * buf_ptr;
  uint8_t buf_len;
} socket_t;

typedef struct socket_msg {
  uint8_t port_nr;
  uint8_t len;
  char buf[BUF_LEN];
} socket_msg_t;

typedef struct port {
  uint8_t socket_nr;
  bool in_use;
} port_t;

typedef uint8_t socket_err_t;

enum {
  SOCKET_SUCCESS = 0,
  SOCKET_ERROR = 1,
  SOCKET_IN_USE = 2,
  SOCKET_ETIMEOUT = 3,
};

#endif /* SOCKET_H */
