{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "geoip-${version}";
  version = "1.6.9";

  src = fetchFromGitHub {
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "2494e9c5678a53da12d3e21a56a700472d630302323c5e7da09e7c2ffcf4bd9c";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    description = "Geolocation API";
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
