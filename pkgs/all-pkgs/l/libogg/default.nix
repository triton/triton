{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libogg-1.3.3";

  src = fetchurl {
    url = "mirror://xiph/ogg/${name}.tar.xz";
    multihash = "QmQfQHGEWrzzUJKWoCH9TNk2LiGPVGB5g4Lq7CL3rY2fri";
    sha256 = "4f3fc6178a533d392064f14776b23c397ed4b9f48f5de297aba73b643f955c08";
  };

  meta = with stdenv.lib; {
    homepage = http://xiph.org/ogg/;
    license = licenses.bsd3;
    maintainers = [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
