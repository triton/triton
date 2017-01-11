{ stdenv
, fetchurl
, perl
}:

let
  version = "1.5.3";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "731df43cb62642a26ac5f58ba0c492bd495c72eca6a9bc777808dfd45471b015";
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
