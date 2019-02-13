{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.5.5";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "a93ae6cbc45639366cd14ec9c4f525faafaa35ce2b7923546e133ec04ee13fc9";
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
