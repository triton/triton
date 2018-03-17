{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.5.2";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "552b0d83a7611435cbafe9c90952cef2c9f043c7a6648b9fa3d81edc7e3220b0";
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
