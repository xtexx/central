`timescale 1ns / 1ps
`default_nettype wire

package ifu_pkg;

  typedef enum logic [1:0] {
    IFUOutSuccess   = 'b00,
    IFUOutTLBRefill = 'b01,
    IFUOutMachErr   = 'b10
  } ifu_out_resp_t;

endpackage
