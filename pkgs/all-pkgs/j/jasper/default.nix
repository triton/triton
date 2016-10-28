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

  version = "1.900.17";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "mdadams";
    repo = "jasper";
    rev = "version-${version}";
    sha256 = "ece87c51e2abf4d06374603596b395b5d51d56206df24d489db21f5f2367f35e";
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
