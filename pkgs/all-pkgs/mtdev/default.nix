{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mtdev-1.1.5";

  src = fetchurl {
    url = "http://bitmath.org/code/mtdev/${name}.tar.bz2";
    sha256 = "0zxs7shzgbalkvlaiibi25bd902rbmkv9n1lww6q8j3ri9qdaxv6";
  };

  meta = with stdenv.lib; {
    homepage = http://bitmath.org/code/mtdev/;
    description = "Multitouch Protocol Translation Library";
    license = licenses.mit;
    maintainers = with maintainers; [ wkennington ];
    platforms = with platforms;
      x86_64-linux;
  };
}
