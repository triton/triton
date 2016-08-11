{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libatomic_ops-7.4.4";

  src = fetchurl {
    url = "http://www.ivmaisoft.com/_bin/atomic_ops/${name}.tar.gz";
    multihash = "QmSYucF6vEfzhFcs4DhJkMnr2Jaxik5kf4hxiyUQGqh5Cn";
    sha256 = "bf210a600dd1becbf7936dd2914cf5f5d3356046904848dcfd27d0c8b12b6f8f";
  };

  meta = with stdenv.lib; {
    description = ''A library for semi-portable access to hardware-provided atomic memory update operations'';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
