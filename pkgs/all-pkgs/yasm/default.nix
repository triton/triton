{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "yasm-1.3.0";

  src = fetchurl {
    url = "http://www.tortall.net/projects/yasm/releases/${name}.tar.gz";
    sha256 = "0gv0slmm0qpq91za3v2v9glff3il594x5xsrbgab7xcmnh0ndkix";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-warnerror"
    "--disable-profiling"
    "--disable-gcov"
    "--disable-python"
    "--disable-python-bindings"
    "--enable-nls"
    "--enable-rpath"
  ];

  meta = with stdenv.lib; {
    description = "An assembler for x86 and x86_64 instruction sets";
    homepage = http://www.tortall.net/projects/yasm/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
