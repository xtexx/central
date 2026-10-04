+libext+.sv+.v

// Packages
rtl/backend/inst_pkg.sv
rtl/frontend/ifu_pkg.sv
vendor/common_cells/src/cc_pkg.sv

// Search path
-y rtl
-y rtl/backend
-y rtl/frontend
-y rtl/gen
-y rtl/interface
-y rtl/macros
-y rtl/utils

// Dependencies
+incdir+vendor/common_cells/include
-y vendor/common_cells/src
-y vendor/taxi/src/prim/rtl
-y vendor/taxi/src/axi/rtl

// Top files
rtl/top.sv
