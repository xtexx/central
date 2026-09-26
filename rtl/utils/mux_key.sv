`timescale 1ns / 1ps
`default_nettype none

module mux_key #(
    parameter int NR_KEY = 2,
    parameter type KEY = logic,
    parameter type DATA = logic
) (
    output DATA out,
    input KEY key,
    input [NR_KEY*($bits(key) + $bits(out))-1:0] lut
);
  mux_key_internal #(
      .NR_KEY(NR_KEY),
      .KEY(KEY),
      .DATA(DATA),
      .HAS_DEFAULT(0)
  ) i0 (
      .out(out),
      .key(key),
      .default_out(DATA'({$bits(DATA) {1'b0}})),
      .lut(lut)
  );
endmodule
