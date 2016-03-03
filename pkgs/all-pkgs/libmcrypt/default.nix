{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libmcrypt-${version}";
  version = "2.5.8";
  
  src = fetchurl {
    url = "mirror://sourceforge/mcrypt/Libmcrypt/${version}/${name}.tar.gz";
    sha256 = "0gipgb939vy9m66d3k8il98rvvwczyaw2ixr8yn6icds9c3nrsz4";
  };

  configureFlags = [
    "--disable-posix-threads"
  ];

  meta = with stdenv.lib; {
    description = "Replacement for the old crypt() package and crypt(1) command, with extensions";
    homepage = http://mcrypt.sourceforge.net;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
