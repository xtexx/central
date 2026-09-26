`timescale 1ns / 1ps
`default_nettype none

module mux_key_internal #(
    parameter int NR_KEY = 2,
    parameter type KEY = logic,
    parameter type DATA = logic,
    parameter bit HAS_DEFAULT = 0
) (
    output DATA out,
    input KEY key,
    input DATA default_out,
    input [NR_KEY*($bits(key) + $bits(out))-1:0] lut
);
  parameter int KEY_LEN  = $bits(KEY);
  parameter int DATA_LEN = $bits(DATA);
  parameter int PAIR_LEN = KEY_LEN + DATA_LEN;
  wire [PAIR_LEN-1:0] pair_list[NR_KEY];
  wire [ KEY_LEN-1:0] key_list [NR_KEY];
  wire [DATA_LEN-1:0] data_list[NR_KEY];

  genvar n;
  generate
    for (n = 0; n < NR_KEY; n = n + 1) begin : g_lut_pairs
      assign pair_list[n] = lut[PAIR_LEN*(n+1)-1 : PAIR_LEN*n];
      assign data_list[n] = pair_list[n][DATA_LEN-1:0];
      assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
    end : g_lut_pairs
  endgenerate

  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;
  integer i;
  always_comb begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
      hit = hit | (key == key_list[i]);
    end
    if (!HAS_DEFAULT) out = DATA'(lut_out);
    else out = (hit ? DATA'(lut_out) : default_out);
  end
endmodule
