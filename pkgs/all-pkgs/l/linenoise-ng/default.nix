{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation {
  name = "linenoise-2016-03-23";

  src = fetchFromGitHub {
    version = 2;
    owner = "arangodb";
    repo = "linenoise-ng";
    rev = "df1cfb41e3de9d2e716016d0571338ceed62290f";
    sha256 = "4bb3a462b080dd2ddaec71dae86353875c7413c16626266fc8a6eb39264a8dec";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
