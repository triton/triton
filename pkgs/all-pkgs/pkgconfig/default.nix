{ stdenv
, fetchurl
}:

stdenv.mkDerivation (rec {
  name = "pkg-config-0.29";
  
  src = fetchurl {
    url = "http://pkgconfig.freedesktop.org/releases/${name}.tar.gz";
    sha256 = "0sq09a39wj4cxf8l2jvkq067g08ywfma4v6nhprnf351s82pfl68";
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
