{ stdenv
, autoreconfHook
, fetchurl
, perl
}:

let
  version = "1.6.1";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "5f160d44ea42ce9352a7a3607bc10d3b4b22d3271763aa3b3a12665e73e3a02d";
  };

  nativeBuildInputs = [
    autoreconfHook
    perl
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
