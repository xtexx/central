`timescale 1ns / 1ps
`default_nettype wire

module mux_key_with_default #(
    parameter int NR_KEY = 2,
    parameter type KEY = logic,
    parameter type DATA = logic
) (
    output DATA out,
    input KEY key,
    input DATA default_out,
    input [NR_KEY*($bits(key) + $bits(out))-1:0] lut
);
  mux_key_internal #(
      .NR_KEY(NR_KEY),
      .KEY(KEY),
      .DATA(DATA),
      .HAS_DEFAULT(1)
  ) i0 (
      .out(out),
      .key(key),
      .default_out(default_out),
      .lut(lut)
  );
endmodule
