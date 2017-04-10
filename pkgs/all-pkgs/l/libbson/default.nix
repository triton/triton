{ stdenv
, autoreconfHook
, fetchurl
, perl
}:

let
  version = "1.6.2";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "aad410123e4bd8a9804c3c3d79e03344e2df104872594dc2cf19605d492944ba";
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
