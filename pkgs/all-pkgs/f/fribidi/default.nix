{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "2017-12-05";
in
stdenv.mkDerivation rec {
  name = "fribidi-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "fribidi";
    repo = "fribidi";
    rev = "0efbaa9052320a951823a6e776b30a580e3a2b4e";
    sha256 = "f62f9292d55f476208a356bb616549b39bdbacdfcba7e2b72815462b1a809be7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildParallel = false;

  meta = with lib; {
    description = "GNU implementation of the Unicode Bidirectional Algorithm";
    homepage = https://github.com/fribidi/fribidi;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
