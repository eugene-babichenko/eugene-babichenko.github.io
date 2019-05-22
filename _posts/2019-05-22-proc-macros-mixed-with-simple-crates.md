---
layout: post
title: Convenient Rust crates with procedural macros and runnable code
date: 2019-05-22 13:00:00 +0300
categories: rust proc-macro cargo crates
---

Procedural macros in Rust are a great thing for many purposes (implementing
custom derives, domain-specific languages inside Rust, etc). However, the use of
procedural macros imposes one very inconvenient constraint: a crate that defines
procedural macros can export nothing but procedural macros. This usually leads
us to usi multiple crates to do exactly one thing (remember `serde` and
`serde_derive`?). In this article, I will review an approach to this problem I
have seen in the [`failure`][failure] crate that allows us to import exactly one
crate.

## The project structure

All libraries I have seen so far rely on workspaces when they need to build a
"simple" crate and a `proc-macro` crate. The generic structure for that is:

```
workspace
├── lib_crate/
├── proc_macro_crate/
└── Cargo.toml
```

with `Cargo.toml` that looks like that:

```toml
[workspace]
members =  ["lib_crate", "proc_macro_crate"]
```

Usually, `lib_crate` contains the definitions of traits, structures and
procedures and `proc_macro_crate` contains procedural macros that generate code
which reuses definitions from `lib_crate`.

## The actual trick

In many libraries what you need to do is to import two crates:

```rust
#[macro_use]
extern crate proc_macro_crate;
extern crate lib_crate;
```

If you don't want your users to do that, you can use a pretty simple hack. Cargo
does not prohibit to re-export procedural macros, so you can just re-export them
in your `lib_crate`!

`lib_crate/Cargo.toml`:

```toml
[dependencies]
proc_macro_crate = { path = "../proc_macro_crate", version = "0.1.0" }
```

`lib_crate/src/lib.rs`:

```rust
#[macro_use]
extern crate proc_macro_crate;

pub use proc_macro_crate::*;
```

As they do not need to import two separate crates anymore `Cargo.toml` and their
code look a bit cleaner.

[failure]: https://github.com/rust-lang-nursery/failure
