{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  version = "1.6.11";
in
stdenv.mkDerivation rec {
  name = "geoip-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "40b289dc9ce7ad9a509fc3f4c5c9a5727ad591be28818f3f3173b24d9a317996";
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
