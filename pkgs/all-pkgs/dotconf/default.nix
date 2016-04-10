{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "dotconf-${version}";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "williamh";
    repo = "dotconf";
    rev = "v${version}";
    sha256 = "dc3cba9439c9841393fe708dc1d7d927bf52aca5ea02fd87ef53d2b5be589001";
  };

  buildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    description = "A configuration parser library";
    homepage = http://www.azzit.de/dotconf/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
