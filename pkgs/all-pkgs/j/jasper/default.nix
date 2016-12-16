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

  version = "2.0.6";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "mdadams";
    repo = "jasper";
    rev = "version-${version}";
    sha256 = "acfae7287d5730ee8a33d522c51e435cfc6640a96e38b4e0c1a0c0bec3aca4b0";
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
