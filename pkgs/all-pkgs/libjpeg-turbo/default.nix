{ stdenv
, fetchurl
, yasm
}:

stdenv.mkDerivation rec {
  name = "libjpeg-turbo-1.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${name}.tar.gz";
    sha256 = "0gi349hp1x7mb98s4mf66sb2xay2kjjxj9ihrriw0yiy0k9va6sj";
  };

  nativeBuildInputs = [
    yasm
  ];

  checkTarget = "test";

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A faster (using SIMD) libjpeg implementation";
    homepage = http://libjpeg-turbo.virtualgl.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
