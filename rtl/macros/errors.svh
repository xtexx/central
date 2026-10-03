`ifndef TYRO_ERRORS_HEADER
`define TYRO_ERRORS_HEADER

`define ERROR(x) \
`ifndef SYNTHESIS \
$error(x) \
`endif \

`endif
