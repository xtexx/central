---
title: "MSI、UEFI与0000424F"
date: 2025-07-29T11:22:04+08:00
tags: ["Computer", "zh", "Quirk"]
aliases: ["/2025/07/29-msi-and-uefi"]
---

你肯定要问，0000424F是什么东西。

一切起源于这个 MSI MAG Z390M MORTAR。
一开始我还在用Windows 10，后来换成了openSUSE Tumbleweed，再后来是AOSC OS。
在安装AOSC OS时，我把ESP分区合并到了 `/boot` 当中，也就是说，我的文件系统长这样：

```text
- / (btrfs)
  - boot (fat32)
    - EFI
      - BOOT
        - BOOTX64.EFI
    - initramfs
    - kernel
```

然后就出事了，AOSC OS的包管理会尝试在更新内核时使用硬链接备份旧的内核，但是FAT32不支持硬连接，dpkg会直接以错误退出，此时需要手动删掉旧的内核再次更新。
GRUB和fwupd等工具也没法自动识别出ESP分区。

今天我打算配置下TPM自动解锁LUKS，于是顺手把ESP分区拆了。于是结构变成了：

```text
- / (btrfs)
  - boot (ext4)
    - esp (fat32)
      - EFI
        - BOOT
          - BOOTX64.EFI
    - initramfs
    - kernel
```

然后就发现，`grub-install`或者`efibootmgr -c`都能创建出一个启动项，`efibootmgr`可以显示出来，但是重启之后这个启动项就消失了。
中途还碰上了`efibootmgr`无法调整启动顺序的bug，是已经被修复的回归，顺手给AOSC OS（[#11893](https://github.com/AOSC-Dev/aosc-os-abbs/pull/11893)）和eweOS（[#4869](https://github.com/eweOS/packages/pull/4869)）都修了。

在加上`--removable`之后，诶，可以了？经过在AOSC OS的贡献者群的讨论，我得知这是MSI早期主板的EFI实现有问题导致的。唉。EDK2还是尽早统一世界吧。

这还没完，我盯着`efibootmgr`看了一会，发现了一个规律。

```text
BootCurrent: 0009
Timeout: 1 seconds
BootOrder: 0000,0009,0005,0006,0001
Boot0000* aosc  HD(1,GPT,xxxxxxx,xxxxxxx,xxxxxxx)/\EFI\AOSC\GRUBX64.EFI0000424F
Boot0001  Hard Drive    BBS(HD,,0x0)/VenHw(xxxxxxx)xxxxxxxxxxxxxxxxxxxxx0000424f
Boot0005  UEFI: PXE IP4 Intel(R) Ethernet Connection (7) I219-V PciRoot(0x0)/Pci(0x1f,0x6)/MAC(xxxxxxx,0)/IPv4(0.0.0.0,0,DHCP,0.0.0.0,0.0.0.0,0.0.0.0)0000424f
Boot0006  UEFI: PXE IP6 Intel(R) Ethernet Connection (7) I219-V PciRoot(0x0)/Pci(0x1f,0x6)/MAC(xxxxxxx,0)/IPv6([::],0,Static,[::],[::],64)0000424f
Boot0009* UEFI OS       HD(1,GPT,xxxxxxx,xxxxxxx,xxxxxxx)/\EFI\BOOT\BOOTX64.EFI0000424f
```

啊，每个启动项后面都有一串不知道哪来的`0000424f`。诶，把它加到手动创建的启动项的路径末尾，还真就~~能用了~~加上去了（经测试没有同时存在removable installation的分区加不上去）。
而且疑似这个魔法适用于部分其他型号的MSI主板，且这个后缀不随型号改变。

啊，但是呢，BIOS还是不能从这个启动项启动。

灵。太灵了。LoongArch都没MSI创。
（我怀疑这个问题和MSI去年的一次固件更新有关，但懒得测试了）

另外，顺便提醒下[MSI有一堆固件默认的Secure Boot设置是不安全的](https://dawidpotocki.com/en/2023/01/13/msi-insecure-boot/)。
