{ stdenv
, fetchurl
, shared ? true
, static ? false
}:

stdenv.mkDerivation rec {
  name = "zlib-${version}";
  version = "1.2.8";

  src = fetchurl {
    urls = [
      "http://www.zlib.net/${name}.tar.gz"
      "mirror://sourceforge/libpng/zlib/${version}/${name}.tar.gz"
    ];
    sha256 = "039agw5rqvqny92cpkrfn243x2gd4xn13hs3xi6isk55d2vqqr9n";
  };

  configureFlags = [
    (if static then "--static" else "")
    (if shared then "--shared" else "")
  ];

  meta = with stdenv.lib; {
    description = "Lossless data-compression library";
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
