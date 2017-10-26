{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, libsass
}:

let
  version = "3.4.5";
in
stdenv.mkDerivation rec {
  name = "sassc-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sass";
    repo = "sassc";
    rev = "${version}";
    sha256 = "c6420496ef63e5e031f406995a7f330ad934df7d350df38f5d7f2cc85d4118e8";
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
