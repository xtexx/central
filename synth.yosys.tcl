yosys -import

read_slang -f tyro-core.yosys.f

check -assert
check_mem -assert -non-const

synth_xilinx -top top -family xc7 -flatten -abc9
bufnorm -bits
opt_clean

write_json synth.json
