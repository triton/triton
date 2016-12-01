{ stdenv
, fetchurl
, perl
}:

let
  version = "1.5.0";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "ba49eeebedfc1e403d20abb080f3a67201b799a05f4a012eee94139ad54a6e6f";
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
