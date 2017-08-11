{ stdenv
, fetchurl
, perl
}:

let
  version = "1.7.0";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "442d89e89dfb43bba1f65080dc61fdcba01dcb23468b2842c1dbdd4acd6049d3";
  };

  nativeBuildInputs = [
    perl
  ];

  configureFlags = [
    "--disable-examples"
    "--disable-tests"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
