#import "examify.typ": *

#show: examify.with(
  paper-size: "a4",
  institute: "无题",
  author: "xtex（Zerozaki Ori）",
  doi: "10.17605/OSF.IO/MTYAQ",
  contact-link: "https://xtexx.eu.org",
  contact-text: "xtexx.eu.org",
  exam-name: "2025普通高中不务正业水平选择性考试适应性演练",
  subject: "译码与执行能力",
  marks: 150,
  class: "A",
  time: "120分钟",
)

#secret

#exam-tips[
  1. 答卷前，考生务必将自己的姓名、考生号、考场号和座位号填写答题卡上，用2B铅笔将试卷类型（A）填涂在答题卡相应位置上，将条形码横贴在答题卡右上角“条形码粘贴处”。
  2. 作答选择题时，选出每小题答案后，用2B铅笔在答题卡上对应题目选项的答案信息点涂黑；如需改动，用橡皮擦干净后，再选涂其他答案。答案不能答在试卷上。写在试卷、草稿纸和答题卡上的非答题区域均无效。
  3. 非选择题必须用黑色字迹的钢笔或签字笔作答，答案必须写在答题卡各题目指定区域内相应位置上；如需改动，先划掉原来的答案，然后再写上新答案；不准使用铅笔和涂改液。不按以上要求作答无效。
  4. 考生必须保持答题卡的整洁。考试结束后，将试卷和答题卡一并交回。
  5. 试题中所有x86-64指令助记符及汇编采用Intel汇编形式，涉及推测译码或执行结果的，如无特殊声明，假定执行环境为长模式，CR寄存器的VMX标志被关闭，通用寄存器、浮点寄存器和向量寄存器均已清零，CPL为Level 0，代码段选择子、数据段选择子和栈段选择子RPL为Level 0，对应的DPL也为Level 0，代码段、数据段、栈段指向相同的内存空间，数据段、栈段可读可写，SSE 2、SSE 3、AVX-512和VMX扩展指令集可用且如果控制寄存器中存在对应的开关，则开关已被打开。
  6. 试题中所有的LoongArch指令助记符及汇编采用官方手册形式，涉及推测译码或执行结果的，如无特殊声明，假定执行环境为PLV0、页表映射地址翻译模式，`$r1`至`$r31`、浮点寄存器和向量寄存器均已清空，LoongArch64、LSX、LASX指令集可用。
  7. 试题中涉及推测译码或执行结果的，如无特殊声明，假定处理器为多核处理器，若操作系统存在，则操作系统识别并利用多核处理器。
  8. 试题中所有“字节”均指8位元组。
]

= 架构理解
== x86-64（共5小题；每小题3分，满分15分）
阅读题目，从每题所给的 A、B、C、D 四个选项中，选出最佳答案。

1. x86-64架构下，以下哪个指令可以在一条指令内将一个64位通用寄存器的值复制到另一个64位通用寄存器中？#ans[A]
  1. `MOV`
  2. `NOP`
  3. `IN`
  4. `VCVTSH2SD`
2. x86-64架构下，以下哪个指令是非特权序列化指令？#ans[C]
  1. `MOV`
  2. `SFENCE`#why[`SFENCE`是内存序指令，不会序列化指令执行流]
  3. `CPUID`
  4. `LGDT`#why[`LGDT`是特权序列化指令]
3. x86-64架构下，以下描述正确的是？#ans[D]
  1. Linux下，所有进程都可以稳定地通过连续两次执行非特权指令`RDTSC`读取TSC，并将其值相减以测定时间。#why[不同处理器的`TSC`计数器相互独立，发生任务中断时，两值不具参考意义]
  2. Linux下，若KVM已被成功启用，VirtualBox仍可以同时使用。#why[KVM启用时会设置VMXON，VirtualBox亦会并产生冲突。]
  3. 欲将32位通用寄存器`EAX`清零，`MOV EAX, 0`是编码最短的方案。#why[`XOR EAX, EAX`仅需2字节，更短]
  4. 分页启用后，MMU仍会在地址转换时考虑分段。
4. x86-64架构下，控制保护模式开关的控制位和页目录基地址分别位于哪两个控制寄存器中？#ans[B]
  1. CR0、CR1
  2. CR0、CR3
  3. CR1、CR1
  4. CR4、CR3
5. x86-64架构下，下列指令中，完全不会修改EFLAGS的是？#ans[A]
  1. `JMP`
  2. `TEST`
  3. `AND`
  4. `CMP`

== LoongArch64（共5小题；每小题3分，满分15分）
阅读题目，从每题所给的 A、B、C、D 四个选项中，选出最佳答案。

1. 龙芯架构中，每条指令编码后的长度是#ans[B]
  1. 1字节
  2. 4字节
  3. 8字节
  4. 因指令而异
2. 访存地址“自然对齐”指的是#ans[C]
  1. 对齐到$e$字节
  2. 对齐到4字节
  3. 对齐到访存长度
  4. 对齐到机器字长
3. 龙芯架构中，取值访存要求地址#ans[D]
  1. 自然对齐
  2. 对齐到访存长度
  3. 对齐到机器字长
  4. 对齐到4字节
4. 龙芯架构中，下列说法正确的是#ans[C]
  1. LASX是龙芯架构的变长指令集扩展。
  2. 不论CSR值如何，PLV3始终不能通过`CSRRD`读取性能计数器。
  3. 访存地址需要自然对齐，转移指令的目标地址也需要对齐。
  4. 访存地址需要自然对齐，转移指令的目标地址不需要对齐。
5. 龙芯架构中，下列说法*不*正确的是#ans[A]
  1. `r0`寄存器为零寄存器是ELF ABI的规定，故可通过`ADD.D %r0, %r0, 1`修改其值。
  2. 龙芯架构是一款由龙芯研发的精简指令集架构。
  3. 龙芯架构只采用小尾端的存储方式。
  4. 龙芯架构中，通用寄存器`r3`被用作栈指针寄存器。

= 解码
== x86-64（共5小题；每小题5分，满分25分）
阅读机器码，从每题所给的 A、B、C、D 四个选项中，选出正确的汇编指令。

1. `B8 00 00 00 00`#ans[A]
  1. `MOV EAX, 0h`
  2. `NOP`
  3. `CMP EAX, 0h`
  4. `INT 0h`
2. `EB 00`#ans[C]
  1. `INT 0h`
  2. `JMP 0`
  3. `JMP 2`
  4. `JMP EAX`
3. `0F 01 C2`#ans[D]
  1. `ENCLV`
  2. `VMXOFF`
  3. `VMXON`
  4. `VMLAUNCH`
4. `F3 FF C8`#ans[C]
  1. `DEC EAX`
  2. `SUB EAX, 1`
  3. `XOR EAX, C8`
  4. `REPZ DEC EAX`
5. `B8 0A 00 00 00`#ans[C]
  1. `MOV EAX, 0A000000h`
  2. `SUB EAX, 0A000000h`
  3. `MOV EAX, 0Ah`
  4. `SUB EAX, 0Ah`

== LoongArch64（共5小题；每小题5分，满分25分）
阅读机器码，从每题所给的 A、B、C、D 四个选项中，选出正确的汇编指令。

1. `03 00 80 03`#ans[C]
  1. `ST.D $r3, $r3, 0`
  2. `LD.D $r3, $r3, 0`
  3. `ORI $r3, $r0, 0`
  4. `ANDI $r3, $r0, 0`
2. `00 00 2A 00`#ans[C]
  1. `B 0`
  2. `SYSCALL 0`
  3. `BREAK 0`
  4. `DBAR 0`
3. `A0 31 C0 2A`#ans[C]
  1. `LD.D $r0, $t3, 12`
  2. `LD.D $r0, $t1, 12`
  3. `PRELD 0, $t1, 12`
  4. `PRELDX 0, $t1, $r12`
4. `21 04 57 38`#ans[A]
  1. `SC.Q $ra, $ra, $ra`
  2. `ORI $r0, $r0, 0`
  3. `SC.D $ra, $ra, 1`
  4. `ST.D $ra, $ra, 1`
5. `21 48 1e 01`#ans[D]
  1. `FRINT.S $r1, $r1`
  2. `FRINT.D $r1, $r1`
  3. `FRINT.S $f1, $f1`
  4. `FRINT.D $f1, $f1`

= 执行
== x86-64（共5小题；每小题5分，满分25分）
阅读汇编代码，从每题所给的 A、B、C、D 四个选项中，选出符合要求的结果描述。

1. ```asm
MOV EAX, 10
REPZ DEC EAX
```
  代码运行结果描述正确的是#ans[A]
  1. `EAX`为0。
  2. `EAX`为1。
  3. `EAX`为10。
  4. 产生`#DIV0`异常。
2. ```asm
CLI
INT 3
STI
```
  代码运行结果描述正确的是#ans[A]
  1. 由于`CLI`，不会触发中断。
  2. 在`INT 3`处触发3号中断。
  3. 在`STI`处触发3号中断。
  4. 产生`#GP`异常。
3. ```asm
JMP 0
```
  代码运行结果描述正确的是#ans[D]
  1. 产生`#GP`异常。
  2. 产生`#UD`异常。
  3. 产生死循环。
  4. 等效于无操作。
4. ```asm
; XMM2 = 0xFFFF000000000000
; 其中，[4096-8191]为一个有效页面，[8192-12287]是无效页面。
VMASKMOVPS XMM1, XMM2, 8190
```
  代码运行结果描述正确的是#ans[D]
  1. 由于缺页而等效于无操作。
  2. 由于缺页而产生`#GP`异常。
  3. 将8190-8191的值左移112位存入`XMM1`，低112位未修改。
  4. 将8190-8191的值左移112位存入`XMM1`，低112位清零。#why[#link("https://arxiv.org/abs/2304.07940")[[2304.07940] AVX Timing Side-Channel Attacks against Address Space Layout Randomization]]
5. ```asm
0x1000: MOV BYTE [0x1007], 0xCC
0x1007: NOP
```
  代码运行结果描述正确的是#ans[B]
  1. 内存0x1007处被修改为0xCC，此外无操作。
  2. 内存0x1007处被修改为0xCC，但不一定触发3号中断。
  3. 内存0x1007处被修改为0xCC，并一定触发3号中断。
  4. 由于代码修改自身而触发`#GP`中断。

== LoongArch64（共3小题；每小题5分，满分15分）
阅读汇编代码，从每题所给的 A、B、C、D 四个选项中，选出符合要求的结果描述。

1. ```asm
ORI $r0, $r0, 1
```
  代码运行结果描述正确的是#ans[A]
  1. 等效于无操作。
  2. `r0`的值为1。
  3. `r0`的值未定义。
  4. 产生异常中断。
2. ```asm
B 0
```
  代码运行结果描述正确的是#ans[B]
  1. 等效于无操作。
  2. 产生死循环。
  3. 该汇编代码无效。
  4. 产生异常中断。
3. ```asm
B 1
```
  代码运行结果描述正确的是#ans[C]
  1. 无副作用。
  2. 由于目标地址为立即数左移2位后加上`PC`，等效于无操作。
  3. 该汇编代码无效。
  4. 由于目标地址未对齐，产生异常中断。

= 作文（30分）
阅读文本，补全两段x86-64汇编，选好角度、确定文意、不得套作、不得抄袭、使用Intel汇编语法、不得使用特权指令、不得使用虚拟化指令、向量指令或浮点指令、可使用Linux系统调用、可使用nasm预处理语法、内容积极向上，30指令左右。

```asm
org 0x7c00
bits 32

main:
  jmp decrypt

flag: dd 12345
v0: dd 4984
v1: dd 132456
sum: dd 0
password: dd 0xB95ECB53, 0x2FBF6EF4, 0xBA6ACC36, 0xA8C730E8, 0xFC8780F7, 0x6296224, 0xAA79B131, 0x3C151A79
%define k0 0x1dbb6bf5
%define k1 0xb00d45c5
%define k2 0xb12c0fee
%define k3 0x8309e9ff
%define DELTA 0x9E3779B9

decrypt:
  mov [flag], eax
  mov eax, 4
  mov ebx, password
  .chunk:
  ; load data
  mov ecx, [ebx]
  mov [v0], ecx
  mov ecx, [ebx + 4]
  mov [v1], ecx
  pushad
  call decipher
  popad
  ; cmp
  mov ecx, [v0]
  mov edx, dword [flag]
  mov edx, [edx]
  cmp edx, ecx
  jne end
  mov ecx, [v1]
  mov edx, dword [flag]
  mov edx, [edx + 4]
  cmp edx, ecx
  jne end
  add dword [flag], 8

  add ebx, 8
  dec eax
  cmp eax, 0
  jne .chunk
end:
  dyn_insn:
  db 0xCC, 10
  db 0x12, 0x13, 0x14, 0x15, 0x13, 0x12, 0x00, 0x11, 0x45, 0x14 ; rand

  int 3

decipher:
  mov dword [sum], 0xC6EF3720
  mov eax, 32
  .round:
  pushad
  call decipher_round
  popad
  dec eax
  cmp eax, 0
  jne .round
  ret

decipher_round:
  ; eax = ((v0 << 4) + k2)
  mov eax, [v0]
  shl eax, 4
  add eax, k2
  ; ebx = (v0 + sum)
  mov ebx, [v0]
  add ebx, [sum]
  ; ecx = ((v0 >> 5) + k3)
  mov ecx, [v0]
  shr ecx, 5
  add ecx, k3
  ; eax = eax ^ ebx ^ ecx
  xor eax, ebx
  xor eax, ecx
  ; v1 -= eax
```
#writing-area(lines: 13)[`sub [v1], eax`]
#why[```asm
  sub [v1], eax
  ; eax = ((v1 << 4) + k0)
  mov eax, [v1]
  shl eax, 4
  add eax, k0
  ; ebx = (v1 + sum)
  mov ebx, [v1]
  add ebx, [sum]
  ; ecx = ((v1 >> 5) + k1)
  mov ecx, [v1]
  shr ecx, 5
  add ecx, k1
```]
```asm
  ; eax = eax ^ ebx ^ ecx
  xor eax, ebx
  xor eax, ecx
```
#writing-area(lines: 13)[`mov byte [dyn_insn], 0xeb ; JMP rel8`]
#why[```asm
  mov byte [dyn_insn], 0xeb ; JMP rel8
  pushad
  cpuid
  popad
```]
```asm
  ; v0 -= eax
  sub [v0], eax
  ; sum -= DELTA
  sub dword [sum], DELTA
  ret
```
