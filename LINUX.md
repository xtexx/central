# Linux kernel for HyperPsi for KLTE devices

Upstreams:
- [Linux Mainline (torvalds' tree)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)
- [Android Common Kernel](https://android.googlesource.com/kernel/common/)
- [MSM8974-mainline](https://github.com/msm8974-mainline/linux.git)

## Changes

### HyperPsi-only

- **ramoops**: ARM: dts: qcom: msm8974pro: add ramoops range (ec95dc048a56)
- **defconfigs**:
   - ARM: config: klte: Add klte defconfig for postmarketOS (233a882f9d0a)
   - ARM: config: Add postmarketOS extra config for samsung-klte (4b07f7342b3b)

### Upstream-queued

This list tracks all changes in this tree that have been sent to upstream and is waiting for review.

-  input: max1187x: Fix uninitialized variable usage (02bec64e18b0)

   <https://github.com/msm8974-mainline/linux/pull/10>

-  - ARM: dts: qcom: msm8974-klte-common: Pin WiFi board type (9696f422c7de)
   - dt-bindings: arm: qcom: Add Samsung Galaxy S5 China (kltechn) (cc20f583e1e0)
   - ARM: dts: qcom: msm8974: Add DTS for Samsung Galaxy S5 China (kltechn) (40388dfb1497)

   <https://patchwork.kernel.org/project/linux-arm-msm/list/?series=820557>

   Rebased to use without patch 1/4.
