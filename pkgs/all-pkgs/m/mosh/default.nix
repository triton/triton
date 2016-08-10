{ stdenv
, fetchurl

, libutempter
, ncurses
, openssl
, protobuf-cpp
, zlib
}:

stdenv.mkDerivation rec {
  name = "mosh-1.2.5";

  src = fetchurl {
    url = "http://mosh.mit.edu/${name}.tar.gz";
    sha256 = "1qsb0y882yfgwnpy6f98pi5xqm6kykdsrxzvaal37hs7szjhky0s";
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
