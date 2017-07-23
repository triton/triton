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
  name = "mosh-1.3.2";

  src = fetchurl {
    url = "https://mosh.mit.edu/${name}.tar.gz";
    multihash = "QmY8gYBKr77eATh4i1LZFAz39Tb4USELiQ2Neev7nYodyf";
    sha256 = "da600573dfa827d88ce114e0fed30210689381bbdcff543c931e4d6a2e851216";
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
