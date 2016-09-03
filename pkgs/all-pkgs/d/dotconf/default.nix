{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "dotconf-${version}";
  version = "1.3";

  src = fetchFromGitHub {
    version = 1;
    owner = "williamh";
    repo = "dotconf";
    rev = "v${version}";
    sha256 = "1e3b2e376a7c0c0261003439054fc17de456860f8a93b10e71e26cc5c7225dcd";
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
