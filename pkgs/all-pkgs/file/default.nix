{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.28";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmRwWmva3GTA6pM1YTnpLeGLHyqxobC3arVNuqyFsfZgy8";
    sha256 = "04p0w9ggqq6cqvwhyni0flji1z0rwrz896hmhkxd2mc6dca5xjqf";
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
