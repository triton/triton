{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "lcms-1.19";

  src = fetchurl {
    url = "mirror://sourceforge/lcms/${name}.tar.gz";
    sha256 = "1abkf8iphwyfs3z305z3qczm3z1i9idc1lz4gvfg92jnkz5k5bl0";
  };

  meta = with stdenv.lib; {
    description = "Color management engine";
    homepage = http://www.littlecms.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
