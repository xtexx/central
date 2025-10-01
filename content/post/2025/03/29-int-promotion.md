---
title: "Passing integers on 64-bits machines"
date: 2025-03-29T09:55:30+08:00
aliases: ["/2025/03/29-int-promotion"]
---

Now is the world of 64-bits architectures, x86-64, AArch64, RISC-V 64, everywhere is 64-bits architectures.

However, even on 64-bits platforms, the `int` and `unsigned int` in C are still 32-bits integers. In the real world, there are lots of code processing `int` (32-bits integer), `short` (16-bits), `char` (8-bits), `bool` (1-bit) and their unsigned variants. In Zig, things are more customizable, you can use `{u,i}{0-64}` to correspond integers from zero-bits to 64-bits.

However again, on those 64-bits platforms, if the architecture has registers (almost all architectures), then all general-purpose registers are 64-bits. So how are the integers stored and passed through procedure borders?

Obviously, $[0, 2^{64}-1]$ covers $[0, 2^{n}-1], 0 \leq n \leq 64$, so all integers whose bit-width is in $[0, 64]$ can be represented with a 64-bits integer and can be stored into a 64-bits GP register.

But when it comes to arithmetic operations, things became more complex. When a smaller integer is stored in a larger (longer) register, what should be in the higher bits?

## The current world

ABI specifications (especially the calling convention specifications) generally define how those integers smaller than 64-bits should be stored when passed as a function argument.

There is [a blog post](https://devblogs.microsoft.com/oldnewthing/20250324-00/?p=110988) on The Old New Thing showing how 32-bits integers are passed in Windows, and their conclusion is that the behavior is related to if the architecture supports 32-bits arithmetic instructions.

There are three kinds of behaviors used by different ABIs:

- Always: no matter the integer is signed or not, sign-extend it to 64-bits.
- Follow: sign-extend signed 32-bits integers to 64-bits, and zero-extend unsigned integers.
- Garbage: the higher bits can have anything.

| ABI variant        | Policy  | 32-bit arithmetic instructions? |
| ------------------ | ------- | ------------------------------- |
| x86-64, Windows    | Garbage | Yes                             |
| x86-64, System V   | Garbage | Yes                             |
| RISC-V, Windows    | Always  | Yes                             |
| RISC-V, psABI      | Always  | Yes                             |
| LoongArch64, psABI | Always  | Yes                             |
| IA64, Windows      | Garbage | Yes                             |
| AArch64, Windows   | Garbage | Yes                             |
| POWER3, Windows    | Follow  | Yes                             |
| MIPS64, Windows    | Always  | No                              |
| Alpha AXP, Windows | Always  | No                              |

It seems that the conclusion from the above blog post is (partially) right. RISC-V and LoongArch seem to be the exceptions, which I will mention later.

This is the case for 32-bits integers. What about others?

For integers smaller than 32-bits, C have a behavior called [integer promotion](https://en.cppreference.com/w/c/language/conversion#Integer_promotions) which is a part of implicit conversions. This behavior will zero-extend those integers to the 32-bits ones.

For integers larger than 32-bits but smaller than 64-bits, I am sad that many ABIs lack definitions for them.

When I was searching for information yesterday, I found a weird behavior of C: they convert signed 32-bits integers to unsigned when comparing signed and unsigned ones, thus `-1 > (unsigned)0` is true.

## Why?

The advantage of leaving garbage in the higher bits is that we don't need to take care of them and don't have to set them to the proper state when passing arguments or after some operations, so almost all architectures with 32-bits arithmetic operation support leave garbage.

For others, why should the unsigned integers be sign-extended anyway? Let's look at the requirements by different integer operations.

- add/sub: Obviously, the result does not change with what is in the higher bits, so it does not matter unless you want to know if overflow happens.
- add/sub with overflow: If garbage is there, we must clear all of those with zero or one. If zero, we can simply check the $n+1$ bit to know if overflow has happened. If one, overflow will be propagated to the highest bit and overflow. On some architectures supporting things like EFLAGS, EFLAGS can be read to know if overflow, but it is not available on most RISC ISAs.
- mul/div: It just cannot be of garbage.
- logic shift right: Higher bits must be zero.
- arithmetic shift right: Must be sign-extended.
- and/or/xor/shift left: Higher bits does not matter the result.
- comparison: The higher bits cannot be garbage, both setting to one or zero or sign-extending are fine.

There are three kinds: can be anything, cannot be garbage, must be zero, must be zero/one, must be sign-extended.

Setting to sign-extended or zero-extended meets the requirements of "can be anything", "cannot be garbage" and "must be zero/one". So there is actually only two cases. I am not sure which is better.

As mentioned above, RISC-V and LoongArch are seemingly weird. They do support 32-bits arithmetic/bit-shifting instructions in 64-bits mode but still require integers to be sign-extended. Why not garbage?

There is one missing thing: comparing. Their conditional control transfer instructions compare the whole register, unable to compare only the lower bits. This is possibly the reason why the higher bits must be synchronized.

From another point of view, let's look at the complexity to do sign-extend and zero-extend. Both two architectures do sign-extend all integers after arithmetic/bit-shifting operations, so possibly designing ABI to require sign-extended integers are because of the processor design.

> The compiler and calling convention maintain an invariant that all 32-bit values are held in a sign-extended format in 64-bit registers. Even 32-bit unsigned integers extend bit 31 into bits 63 through 32.
>
> -- RISC-V Instruction Set Manual Volume I

In my opinion, designing the processor to zero-extend all numbers seems to be easy. So this may be a simple random choice.

Just realized that I did a lot of bike-shedding. Oh no!
