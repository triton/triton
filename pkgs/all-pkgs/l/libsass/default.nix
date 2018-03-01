{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.4.9";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "bb02f5c37d3b0abfdf32c128aac87e835c7e9fdd63a40a40d18801d139a6a1bc";
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
