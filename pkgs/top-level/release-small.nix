/* A small release file, with few packages to be built.  The aim is to reduce
   the load on Hydra when testing the `stdenv-updates' branch. */

{ nixpkgs ? { outPath = (import ../.. { }).lib.cleanSource ../..; revCount = 1234; shortRev = "abcdef"; }
, supportedSystems ? [ "x86_64-linux" "i686-linux" ]
}:

let
  release-lib = import ./release-lib.nix {
    inherit supportedSystems;
    allPackages = nixpkgs;
  };

  inherit (release-lib)
    lib
    mapTestOn;

  inherit (lib.platforms)
    all;
in
{
  tarball = import ./make-tarball.nix {
    inherit nixpkgs;
    officialRelease = false;
  };
} // (mapTestOn (rec {
  bash = all;
  fish = all;
  git = all;
  gnupg = all;
  openssh = all;
  screen = all;
  stdenv = all;
  tmux = all;
  vim = all;
  zsh = all;
}))
