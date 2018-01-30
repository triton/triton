{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "1.6.12";
in
stdenv.mkDerivation rec {
  name = "geoip-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "f4c92ebaf787b0329c7a3549ec250c7c60904d579dc2324d3e14e550c408d37e";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    description = "Geolocation API";
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
