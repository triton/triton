{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkg-config-0.29.1";
  
  src = fetchurl {
    url = "http://pkgconfig.freedesktop.org/releases/${name}.tar.gz";
    sha256 = "00dh1jn8rbppmgbhhgqhmbh3c58b0gccy39rsjdlcma50sg3rd5y";
  };

  configureFlags = [
    "--with-internal-glib"
  ];

  meta = with stdenv.lib; {
    description = "A tool that allows packages to find out information about other packages";
    homepage = http://pkg-config.freedesktop.org/wiki/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
