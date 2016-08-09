{ stdenv
, fetchurl

, libogg
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    platforms;
in
stdenv.mkDerivation rec {
  name = "flac-1.3.1";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/flac/${name}.tar.xz";
    sha256 = "4773c0099dba767d963fd92143263be338c48702172e8754b9bc5103efe1c56c";
  };

  configureFLags = [
    "--enable-largefile"
    "--enable-asm-optimizations"
    "--disable-debug"
    (enFlag "sse" (elem targetSystem platforms.x86-all) null)
    (enFlag "altivec" (elem targetSystem platforms.powerpc-all) null)
    "--disable-thorough-tests"
    "--disable-exhaustive-tests"
    "--disable-werror"
    "--disable-stack-smash-protection"
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

  outputs = [
    "out"
    "doc"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
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
