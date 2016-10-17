{ stdenv
, fetchpatch
, fetchTritonPatch
, fetchurl
, lib

, libjpeg
, mesa
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "jasper-1.900.5";

  src = fetchurl {
    url = "https://www.ece.uvic.ca/~frodo/jasper/software/${name}.tar.gz";
    multihash = "QmafPg972wF8hhQ63q2F1j1RLjxXrr5pWGB48uX8FQtivp";
    sha256 = "d5082e14a50a7e461863991a8e932fc06a1b2f2688108c4478c400c39e257ebb";
  };

  propagatedBuildInputs = [
    libjpeg
    mesa
  ];

  configureFlags = [
    "--enable-shared"
    "--${boolEn (libjpeg != null)}-libjpeg"
    "--${boolEn (mesa != null)}-opengl"
    "--disable-dmalloc"
    "--disable-debug"
    "--disable-special0"
    "--with-x"
  ];

  meta = with lib; {
    description = "JPEG2000 Library";
    homepage = https://www.ece.uvic.ca/~frodo/jasper/;
    license = licenses.free; # JasPer2.0
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
