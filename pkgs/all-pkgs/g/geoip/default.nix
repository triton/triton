{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "geoip-${version}";
  version = "1.6.9";

  src = fetchFromGitHub {
    version = 1;
    owner = "maxmind";
    repo = "geoip-api-c";
    rev = "v${version}";
    sha256 = "bf32c498fdd99af946419ed981b8d93c8eac8d3d01a6f372b68ed8f416b6865c";
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
