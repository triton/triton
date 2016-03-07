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
    sha256 = "0lsp8q35rphjdvls4lks6vs7w6jvmsrri5k6id66x5ci51bqi5l4";
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
