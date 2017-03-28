{ stdenv
, fetchurl

, libutempter
, ncurses
, openssl
, perl
, protobuf-cpp
, zlib
}:

stdenv.mkDerivation rec {
  name = "mosh-1.3.0";

  src = fetchurl {
    url = "https://mosh.mit.edu/${name}.tar.gz";
    multihash = "QmcoCg9yhSfoBVv9n4CJiNh7uQB85kgb4F5YmAAic4EMa2";
    sha256 = "320e12f461e55d71566597976bd9440ba6c5265fa68fbf614c6f1c8401f93376";
  };

  nativeBuildInputs = [
    protobuf-cpp
  ];

  buildInputs = [
    libutempter
    ncurses
    openssl
    perl  # Needed for $out/bin/mosh
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
