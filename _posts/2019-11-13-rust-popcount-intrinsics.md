---
layout: post
title: How to force Rust compiler to use several x86 instructions (popcount, etc)
date: 2019-11-13 21:00:00 +0200
categories: rust popcount optimization tutorial
---

Sometimes you need tricky operations on your binary data like counting bits,
leading or trailing zeros and so on (for example, when you want to implement
[HAMT][hamt] or sparse arrays). In Rust this is achieved by using methods like
`.count_ones()` and `.trailing_zeros()`. The problem with those methods is that
they are usually expanded in a huge pile of assembler code. But x86 (and some
other architectures) have instructions to perform these counts (specifically,
`popcnt` and `tzcnt`) and they are really fast ([1 cycle for execution and
latency of 3 cycles][popcount-latency]). Today we will learn how to force Rust
compiler to use those instructions and what are the possible pitfalls.

Let's start with an example. Here's the code that finds population counts of
random integers ([on Rust Playground][example1]):

```rust
use rand::prelude::*;

// this is only to have this function separately in the asm output
#[inline(never)]
fn count(a: u32) -> u32 {
    a.count_ones()
}

fn main() {
    let a: u32 = random();
    println!("{}", count(a));
    println!("{}", count(a + 1));
}
```

And the `count` function looks like that:

```
playground::count:
	mov	eax, edi
	shr	eax
	and	eax, 1431655765
	sub	edi, eax
	mov	eax, edi
	and	eax, 858993459
	shr	edi, 2
	and	edi, 858993459
	add	edi, eax
	mov	eax, edi
	shr	eax, 4
	add	eax, edi
	and	eax, 252645135
	imul	eax, eax, 16843009
	shr	eax, 24
	ret
```

Wow. A huge pile of instructions and magic numbers. This is clearly not
something we would like to see, especially in performance-critical places. Let's
make this a little bit better ([on Rust Playground][example2]):

```rust
use rand::prelude::*;

// this is only to have this function separately in the asm output
#[inline(never)]
#[cfg_attr(target_arch = "x86_64", target_feature(enable = "popcnt"))]
unsafe fn count(a: u32) -> u32 {
    a.count_ones()
}

fn main() {
    let a: u32 = random();
    println!("{}", unsafe { count(a) });
    println!("{}", unsafe { count(a + 1) });
}
```

And here is the assembly code of `count`:

```
playground::count:
	popcnt	eax, edi
	ret
```

Only a single [very fast][popcount-latency] instruction! And that this will work
with all integer types. There is a pitfall though: Rust requires us to mark
functions as `unsafe` when we use `target_feature` so it makes sense to make
functions using those features as small as possible.

Also, you can do something similar with `.trailing_zeros()` or
`.leading_zeros()` by using `target_feature(enable = "bmi1")`.

To find feature names you can refer to architecture-specific [intrinsics
documentation][intrinsics-docs].

That's all, hope you find it useful!

[popcount-latency]: https://software.intel.com/en-us/forums/intel-isa-extensions/topic/289168
[intrinsics-docs]: https://doc.rust-lang.org/std/intrinsics/index.html
[hamt]: https://en.wikipedia.org/wiki/Hash_array_mapped_trie
[example1]: https://play.rust-lang.org/?version=stable&mode=release&edition=2018&gist=2551cbb6a41adad36e45bc50bf26c3bb
[example2]: https://play.rust-lang.org/?version=stable&mode=release&edition=2018&gist=a91e315224c79f2d6c72bb85d3fdfe2d 
