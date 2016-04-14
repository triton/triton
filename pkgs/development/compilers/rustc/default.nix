{ stdenv, callPackage }:

callPackage ./generic.nix {
  shortVersion = "1.8.0";
  isRelease = true;
  forceBundledLLVM = true;
  configureFlags = [ "--release-channel=stable" ];
  srcSha = "af4466147e8d4db4de2a46e07494d2dc2d96313c5b37da34237f511c905f7449";

  /* Rust is bootstrapped from an earlier built version. We need
  to fetch these earlier versions, which vary per platform.
  The shapshot info you want can be found at
  https://github.com/rust-lang/rust/blob/{$shortVersion}/src/snapshots.txt
  with the set you want at the top. Make sure this is the latest snapshot
  for the tagged release and not a snapshot in the current HEAD.
  */

  sha1Linux686 = "5f194aa7628c0703f0fd48adc4ec7f3cc64b98c7";
  sha256Linux686 = "05f4v6samvkwsv6a7jp9sxsm84s0gdvqyf2wwdi1ilg9k8nxzgd4";
  sha1Linux64 = "d29b7607d13d64078b6324aec82926fb493f59ba";
  sha256Linux64 = "8deb8b687cb7d89ea943745c16c1061225fcbb5c64c0c121cdd1cb68673e683e";
  snapshotDate = "2016-02-17";
  snapshotRev = "4d3eebf";

  patches = [ ./patches/remove-uneeded-git.patch ];
}
