{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "3.5.4";
in
stdenv.mkDerivation rec {
  name = "libsass-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sass";
    repo = "libsass";
    rev = "${version}";
    sha256 = "7cc7cc6efa46b92e97fc6287c94a119425695b671f2867bc7edf795ed752b9fc";
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
