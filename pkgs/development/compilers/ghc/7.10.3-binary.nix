{ stdenv, fetchurl, perl, ncurses, gmp, makeWrapper }:

stdenv.mkDerivation rec {
  version = "7.10.3";

  name = "ghc-${version}-binary";

  src =
    if stdenv.system == "i686-linux" then
      fetchurl {
        url = "http://downloads.haskell.org/~ghc/${version}/ghc-${version}-i386-deb8-linux.tar.xz";
        sha256 = "0gny7knhss0w0d9r6jm1gghrcb8kqjvj94bb7hxf9syrk4fxlcxa";
      }
    else if stdenv.system == "x86_64-linux" then
      fetchurl {
        url = "http://downloads.haskell.org/~ghc/${version}/ghc-${version}-x86_64-deb8-linux.tar.xz";
        sha256 = "15hv4z6hf27vq19l8kvrn7p03sa4pacgcghks0a9cj5zmy1f4y5l";
      }
    else if stdenv.system == "x86_64-darwin" then
      fetchurl {
        url = "http://downloads.haskell.org/~ghc/${version}/ghc-${version}-x86_64-apple-darwin.tar.xz";
        sha256 = "1imzqc0slpg0r6p40n5a9m18cbcm0m86z8dgyhfxcckksw54mzwa";
      }
    else throw "cannot bootstrap GHC on this platform";

  nativeBuildInputs = [ perl ];

  postUnpack =
    # Strip is harmful, see also below. It's important that this happens
    # first. The GHC Cabal build system makes use of strip by default and
    # has hardcoded paths to /usr/bin/strip in many places. We replace
    # those below, making them point to our dummy script.
     ''
      mkdir "$TMP/bin"
      for i in strip; do
        echo '#! ${stdenv.shell}' > "$TMP/bin/$i"
        chmod +x "$TMP/bin/$i"
      done
      PATH="$TMP/bin:$PATH"
     '' +
    # We have to patch the GMP paths for the integer-gmp package.
     ''
      find . -name integer-gmp.buildinfo \
          -exec sed -i "s@extra-lib-dirs: @extra-lib-dirs: ${gmp}/lib@" {} \;
     '' +
    # We have to patch shebangs
      ''
        patchShebangs .
      '' +
    # On Linux, use patchelf to modify the executables so that they can
    # find editline/gmp.
    ''
      mkdir -p "$out/lib"
      ln -sv "${ncurses}/lib/libncurses.so" "$out/lib/libncursesw.so.5"
      find . -type f -perm -0100 \
          -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$out/lib:${gmp}/lib" {} \;
      sed -i "s|/usr/bin/perl|perl\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      sed -i "s|/usr/bin/gcc|gcc\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      for prog in ld ar gcc strip ranlib; do
        find . -name "setup-config" -exec sed -i "s@/usr/bin/$prog@$(type -p $prog)@g" {} \;
      done
     '';

  configurePhase = ''
    ./configure --prefix=$out \
      --with-gmp-libraries=${gmp}/lib --with-gmp-includes=${gmp}/include
  '';

  # Stripping combined with patchelf breaks the executables (they die
  # with a segfault or the kernel even refuses the execve). (NIXPKGS-85)
  dontStrip = true;

  # No building is necessary, but calling make without flags ironically
  # calls install-strip ...
  buildPhase = "true";

  postInstall = ''
    # Sanity check, can ghc create executables?
    cd $TMP
    mkdir test-ghc; cd test-ghc
    cat > main.hs << EOF
      {-# LANGUAGE TemplateHaskell #-}
      module Main where
      main = putStrLn \$([|"yes"|])
    EOF
    $out/bin/ghc --make main.hs || exit 1
    echo compilation ok
    [ $(./main) == "yes" ]
  '';

  meta.license = stdenv.lib.licenses.bsd3;
  meta.platforms = ["x86_64-linux" "i686-linux" "x86_64-darwin"];
}
