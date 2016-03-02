{ pkgs, callPackage, stdenv }:

let
  ghc7103Binary = callPackage ../development/compilers/ghc/7.10.3-binary.nix { };

  ghc7103BinaryPkgs = callPackage ../development/haskell-modules {
    ghc = ghc7103Binary;
    compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-7.10.x.nix { };
  };
in
rec {

  lib = import ../development/haskell-modules/lib.nix { inherit pkgs; };

  compiler = {

    ghc7103 = callPackage ../development/compilers/ghc/7.10.3.nix {
      ghc = ghc7103Binary;
      inherit (ghc7103BinaryPkgs) hscolour;
    };
    ghc801 = callPackage ../development/compilers/ghc/8.0.1.nix {
      ghc = ghc7103Binary;
      inherit (ghc7103BinaryPkgs) hscolour;
    };

  };

  packages = {

    ghc7103 = callPackage ../development/haskell-modules {
      ghc = compiler.ghc7103;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-7.10.x.nix { };
    };

    ghc801 = callPackage ../development/haskell-modules {
      ghc = compiler.ghc801;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.0.x.nix { };
    };

  };
}
