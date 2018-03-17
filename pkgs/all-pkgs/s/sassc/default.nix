{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, libsass
}:

let
  version = "3.5.0";
in
stdenv.mkDerivation rec {
  name = "sassc-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sass";
    repo = "sassc";
    rev = "${version}";
    sha256 = "02e2a6b00f08d3989d1b47984664c36d27523ababe3a8d0d515deffb259368e6";
  };

  postPatch = ''
    export SASSC_VERSION="${version}"
  '';

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libsass
  ];

  meta = with lib; {
    description = "A front-end for libsass";
    homepage = https://github.com/sass/sassc/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
