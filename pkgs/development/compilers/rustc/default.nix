{ stdenv, callPackage }:

callPackage ./generic.nix {
  shortVersion = "1.7.0";
  isRelease = true;
  forceBundledLLVM = true;
  configureFlags = [ "--release-channel=stable" ];
  srcSha = "05f4v6sfmvkwsv6a7jp9sxsm84s0gdvqyf2wwdi1ilg9k8nxzgd4";

  /* Rust is bootstrapped from an earlier built version. We need
  to fetch these earlier versions, which vary per platform.
  The shapshot info you want can be found at
  https://github.com/rust-lang/rust/blob/{$shortVersion}/src/snapshots.txt
  with the set you want at the top. Make sure this is the latest snapshot
  for the tagged release and not a snapshot in the current HEAD.
  */

  sha1Linux686 = "a09c4a4036151d0cb28e265101669731600e01f2";
  sha256Linux686 = "05f4v6sfmvkwsv6a7jp9sxsm84s0gdvqyf2wwdi1ilg9k8nxzgd4";
  sha1Linux64 = "97e2a5eb8904962df8596e95d6e5d9b574d73bf4";
  sha256Linux64 = "1rsh57dm4sx0cb35zaz2pmxxnzj21kp05svb653kzr1wcw1m5p58";
  snapshotDate = "2015-12-18";
  snapshotRev = "3391630";

  patches = [ ./patches/remove-uneeded-git.patch ];
}
