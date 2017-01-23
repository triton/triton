{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libdaemon-0.14";

  src = fetchurl {
    url = "http://0pointer.de/lennart/projects/libdaemon/${name}.tar.gz";
    multihash = "QmcDvHt8nSKJS3ocvWvipKpoUP261MjWLnu19zy7M9RNrQ";
    sha256 = "0d5qlq5ab95wh1xc87rqrh1vx6i8lddka1w3f1zcqvcqdxgyn8zx";
  };

  configureFlags = [
    "--disable-lynx"
  ];

  meta = with stdenv.lib; {
    description = "Lightweight C library that eases the writing of UNIX daemons";
    homepage = http://0pointer.de/lennart/projects/libdaemon/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
