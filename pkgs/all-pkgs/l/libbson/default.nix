{ stdenv
, autoreconfHook
, fetchurl
, perl
}:

let
  version = "1.6.0";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "827b974da1b2eb387e026f5efb7ac7802b87173562cc65ac95b0d332cbdf8d15";
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
