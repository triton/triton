{ stdenv
, fetchurl
, lib

, boost
, cppunit
, zlib
}:

# FIXME: build from master, no releases in a long time

let
  inherit (lib)
    boolEn;

  version = "0.0.4";
in
stdenv.mkDerivation {
  name = "librevenge-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libwpd/librevenge/librevenge-${version}/"
        + "librevenge-${version}.tar.xz";
    sha256 = "1cj76cz4mqcy2mgv9l5xlc95bypyk8zbq0ls9cswqrs2y0lhfgwk";
  };

  buildInputs = [
    boost
    cppunit
    zlib
  ];

  # FIXME
  # Clang generates warnings in Boost's header files
  # -Werror causes these warnings to be interpreted as errors
  # Simplest solution: disable -Werror
  configureFlags = [
    "--${boolEn (!stdenv.cc.isClang)}-werror"
  ];

  # Fix an issue with boost 1.59
  # This is fixed upstream so please remove this when updating
  postPatch = ''
    sed -i src/lib/Makefile.in \
      -e 's,-DLIBREVENGE_BUILD,\0 -DBOOST_ERROR_CODE_HEADER_ONLY,g'
  '';

  NIX_CFLAGS_COMPILE = [
    "-Wno-implicit-fallthrough"
  ];

  meta = with lib; {
    description = "A base library for writing document import filters";
    license = licenses.mpl20 ;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
