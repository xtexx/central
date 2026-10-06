create_clock -name sys_clk -period 25.000 [get_ports { clk }]
create_clock -name io_clk -period 10.000 [get_ports { clk_io_ref }]
