{ stdenv, callPackage }:

callPackage ./generic.nix {
  shortVersion = "1.6.0";
  isRelease = true;
  forceBundledLLVM = false;
  configureFlags = [ "--release-channel=stable" ];
  srcSha = "1dvpiswl0apknizsz9bcrjnc4c43ys191a1b9gm3569xdlmxr36w";

  /* Rust is bootstrapped from an earlier built version. We need
  to fetch these earlier versions, which vary per platform.
  The shapshot info you want can be found at
  https://github.com/rust-lang/rust/blob/{$shortVersion}/src/snapshots.txt
  with the set you want at the top. Make sure this is the latest snapshot
  for the tagged release and not a snapshot in the current HEAD.
  */

  snapshotHashLinux686 = "e2553bf399cd134a08ef3511a0a6ab0d7a667216";
  snapshotHashLinux64 = "7df8ba9dec63ec77b857066109d4b6250f3d222f";
  snapshotDate = "2015-08-11";
  snapshotRev = "1af31d4";

  patches = [ ./patches/remove-uneeded-git.patch ]
    ++ stdenv.lib.optional stdenv.needsPax ./patches/grsec.patch;
}
