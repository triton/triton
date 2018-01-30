{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.4.8";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "2d0b9903bf67205459199db7f9e4a0e0e490017861091db2cb78ac735f8adb70";
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
