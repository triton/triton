{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  version = "1.6.10";
in
stdenv.mkDerivation rec {
  name = "geoip-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "a4e9caaf51edbce6d28b38e40996e851a4a4650a737f70c8f388b1bb37728136";
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
