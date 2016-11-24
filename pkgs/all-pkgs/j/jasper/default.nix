{ stdenv
, autoreconfHook
, fetchpatch
, fetchTritonPatch
, fetchFromGitHub
, lib

, libjpeg
, mesa
}:

let
  inherit (lib)
    boolEn;

  version = "1.900.31";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "mdadams";
    repo = "jasper";
    rev = "version-${version}";
    sha256 = "550c543c88304589f82a9b2f81be053e8708531c3dacae031dbff7f28abb6d87";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
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
