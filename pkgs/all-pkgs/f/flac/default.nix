{ stdenv
, fetchurl
, lib

, libogg
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "flac-1.3.2";

  src = fetchurl {
    url = "mirror://xiph/flac/${name}.tar.xz";
    multihash = "QmZLYKX7bcZtUopiGmMzUCUGJDn1TEgqXvJtUw7M8KtjZU";
    sha256 = "e48764f0761beb791a69590f12826fe8cf302c42db2879849c5d10bc7c85db66";
  };

  configureFlags = [
    "--enable-largefile"
    "--enable-asm-optimizations"
    "--disable-debug"
    "--${boolEn (elem targetSystem platforms.x86-all)}-sse"
    "--${boolEn (elem targetSystem platforms.powerpc-all)}-altivec"
    "--${boolEn (elem targetSystem platforms.x86-all)}-avx"
    "--disable-thorough-tests"
    "--disable-exhaustive-tests"
    "--disable-werror"
    "--disable-stack-smash-protection"
    "--${boolEn (elem targetSystem platforms.bit64)}-64-bit-words"
    "--disable-valgrind-testing"
    "--disable-doxygen-docs"
    "--disable-local-xmms-plugin"
    "--enable-xmms-plugin"
    "--enable-cpplibs"
    "--enable-ogg"
    "--disable-oggtest"
    "--enable-rpath"
  ];

  buildInputs = [
    libogg
  ];

  doCheck = false;

  meta = with lib; {
    description = "FLAC lossless audio file format";
    homepage = http://xiph.org/flac/;
    license = with licenses; [
      bsd3
      fdl12
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
