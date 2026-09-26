`ifndef TYRO_VBITS_HEADER
`define TYRO_VBITS_HEADER

function automatic integer vbits(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction

`endif
