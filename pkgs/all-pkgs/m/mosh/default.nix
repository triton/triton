{ stdenv
, fetchurl

, libutempter
, ncurses
, openssl
, protobuf-cpp
, zlib
}:

stdenv.mkDerivation rec {
  name = "mosh-1.2.6";

  src = fetchurl {
    url = "https://mosh.mit.edu/${name}.tar.gz";
    sha256 = "7e82b7fbfcc698c70f5843bb960dadb8e7bd7ac1d4d2151c9d979372ea850e85";
  };

  nativeBuildInputs = [
    protobuf-cpp
  ];

  buildInputs = [
    libutempter
    ncurses
    openssl
    protobuf-cpp
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://mosh.mit.edu/;
    description = "Mobile shell (ssh replacement)";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
