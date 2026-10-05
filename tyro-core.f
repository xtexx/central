+libext+.sv+.v

// Packages
rtl/backend/inst_pkg.sv
rtl/frontend/ifu_pkg.sv
vendor/common_cells/src/cc_pkg.sv
vendor/axi/src/axi_pkg.sv
vendor/axi/src/axi_intf.sv

// Search path
-y rtl
-y rtl/backend
-y rtl/device
-y rtl/frontend
-y rtl/gen
-y rtl/interface
-y rtl/macros
-y rtl/utils

// Dependencies
+incdir+vendor/common_cells/include
-y vendor/common_cells/src
+incdir+vendor/axi/include
-y vendor/axi/src

// AXI modules whose name is different from file name
vendor/axi/src/axi_lite_xbar.sv

// Top files
rtl/top.sv
