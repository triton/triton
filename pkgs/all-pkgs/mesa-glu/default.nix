{ stdenv
, fetchurl

, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "glu-9.0.0";

  src = fetchurl {
    url = "ftp://ftp.freedesktop.org/pub/mesa/glu/${name}.tar.bz2";
    sha256 = "04nzlil3a6fifcmb95iix3yl8mbxdl66b99s62yzq8m7g79x0yhz";
  };

  buildInputs = [
    mesa_noglu
  ];

  meta = with stdenv.lib; {
    description = "OpenGL utility library";
    homepage = http://cgit.freedesktop.org/mesa/glu/;
    license = licenses.sgi-b-20;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
