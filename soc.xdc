set_ungroup [get_designs cc_cdc_fifo_gray*] false
set_boundary_optimization [get_designs cc_cdc_fifo_gray*] false
set_max_delay min(T_src, T_dst) \
    -through [get_pins -hierarchical -filter async] \
    -through [get_pins -hierarchical -filter async]
set_false_path -hold \
    -through [get_pins -hierarchical -filter async] \
    -through [get_pins -hierarchical -filter async]

set_property PACKAGE_PIN AD23 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN Y23 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
