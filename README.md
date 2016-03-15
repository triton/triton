Triton
======

Triton is a collection of packages for the [Nix](https://nixos.org/nix/) package
manager.

[Triton](https://nixos.org/nixos/) linux distribution source code is located inside
`nixos/` folder.

* [NixOS installation instructions](https://nixos.org/nixos/manual/#ch-installation)
* [Documentation (Nix Expression Language chapter)](https://nixos.org/nix/manual/#ch-expression-language)
* [Manual (How to write packages for Nix)](https://nixos.org/nixpkgs/manual/)
* [Manual (NixOS)](https://nixos.org/nixos/manual/)
* [Nix Wiki](https://nixos.org/wiki/)

##### Supported Platforms `(not all platforms implemented)`
+ `ARM` requires: armv7+
  * `armv7l-linux`
  * `armv8l-linux`
  * `aarch64-linux`
+ `x86` requires: `MMX`,`SSE`,`SSE2`,`SSE3`,`SSSE3`,`SSE4`,`SSE4.1`,`sse4.2`,`VT-x`,`VT-d`
 (aka. at least Intel Nehalem, AMD 14h, or VIA Eden x4)
  * `i686-freebsd` (libs only)
  * `i686-linux` (libs only)
  * `x86_64-freebsd`
  * `x86_64-linux`
+ `POWER` requires: POWER8+
  * `powerpc64le-linux`
