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
    version = 6;
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "6aab70432c755e3063f558401b1c39858cee2c3d253324980f696d0c35f7a3eb";
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
