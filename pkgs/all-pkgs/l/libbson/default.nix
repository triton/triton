{ stdenv
, fetchurl
, perl
}:

let
  version = "1.5.1";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "409bca4a59cb85e3b6b3d72e58518a9fde2c413f4d14dc36e70a3b33e6629729";
  };

  nativeBuildInputs = [
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
