{ stdenv
, fetchurl
, perl
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "63dea744b265a2e17c7b5e289f7803c679721d98e2975ea7d56bc1e7b8586bc1";
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
