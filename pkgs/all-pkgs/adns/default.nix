{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "adns-1.5.0";

  src = fetchurl {
    urls = [
      "mirror://gnu/adns/${name}.tar.gz"
      "http://www.chiark.greenend.org.uk/~ian/adns/ftp/${name}.tar.gz"
      "ftp://ftp.chiark.greenend.org.uk/users/ian/adns/${name}.tar.gz"
    ];
    multihash = "QmUj1XpX2yuKFEJYoqLAqL8b5asTDuAvYgxKxjRkkQEvYS";
    sha256 = "0hg89b5n84zjhzvbzrpvhl0hbm4s6d1z2pzllfis64ai656ypibz";
  };

  meta = with stdenv.lib; {
    homepage = "http://www.chiark.greenend.org.uk/~ian/adns/";
    description = "Asynchronous DNS Resolver Library";
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
