{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, libsass
}:

let
  version = "3.4.8";
in
stdenv.mkDerivation rec {
  name = "sassc-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "sass";
    repo = "sassc";
    rev = "${version}";
    sha256 = "096400650816e68c3db2fe0a3716623cf13a136768396059087270b5f543a766";
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
