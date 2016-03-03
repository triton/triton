{ stdenv
, fetchurl
, makeWrapper
, perl

, gmp
, libffi
, ncurses
}:

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
    else throw "cannot bootstrap GHC on this platform";

  nativeBuildInputs = [
    perl
  ];

  postPatch = ''
    patchShebangs .

    # We don't want to strip binaries during the build process
    mkdir "$TMPDIR/bin"
    echo "#! ${stdenv.shell}" > "$TMPDIR/bin/strip"
    chmod +x "$TMPDIR/bin/strip"
    export PATH="$TMPDIR/bin:$PATH"

    mkdir -p $out/lib
    ln -sv "${ncurses}/lib/libncurses.so" "$out/lib/libtinfo.so.5"

    # We need to patchelf all of the binaries
    find $(pwd) -name \*ghc7.10.3.so -exec cp {} $out/lib \;

    while read file; do
      if patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" 2>/dev/null; then
        patchelf --set-rpath "$out/lib:${gmp}/lib:${libffi}/lib:${stdenv.libc}/lib" "$file"
        if ldd "$file" | grep 'not found'; then
          echo "Failed to find some libraries"
          exit 1
        fi
      fi
    done < <(find . -type f)

    sed -i "s@extra-lib-dirs: @extra-lib-dirs: ${gmp}/lib@" libraries/integer-gmp2/integer-gmp.buildinfo
  '';

  configureFlags = [
    "--with-gmp-libraries=${gmp}/lib"
    "--with-gmp-includes=${gmp}/include"
  ];

  # Stripping combined with patchelf breaks the executables (they die
  # with a segfault or the kernel even refuses the execve). (NIXPKGS-85)
  dontStrip = true;

  # No building is necessary, but calling make without flags ironically
  # calls install-strip ...
  buildPhase = "true";

  /*postInstall = ''
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
  '';*/

  meta.license = stdenv.lib.licenses.bsd3;
  meta.platforms = with stdenv.lib.platforms;
    i686-linux
    ++ x86_64-linux;
}
