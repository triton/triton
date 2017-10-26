{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.4.6";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "20d6aac044d85d8e085fccb6e15c5127bda89e5c80a956bf37b314bf4699d1f4";
  };

  postPatch = ''
    export LIBSASS_VERSION="${version}"
  '';

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    description = "A C/C++ implementation of a Sass compiler";
    homepage = https://github.com/sass/libsass;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
