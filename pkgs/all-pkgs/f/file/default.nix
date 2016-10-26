{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.29";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmVWSJRZqy4rvb4ShPJwRkn21nm2JXYcAY9x8RiBQ67NGy";
    sha256 = "ea661277cd39bf8f063d3a83ee875432cc3680494169f952787e002bdd3884c0";
  };

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    description = "A program that shows the type of files";
    homepage = "http://darwinsys.com/file";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
