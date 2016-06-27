{ stdenv
, fetchurl
, groff

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20160618-3.1";

  src = fetchurl {
    url = "http://www.thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmewmzBgwRCyTNM33YEZXhGiDf4SHxGVJ7UzULB5qm14hr";
    sha256 = "1mpmm62xxh0s3y9c86ic8rn39yhfjs5mv9x2kqs7z2pcqv05kcdn";
  };

  # Have `configure' avoid `/usr/bin/nroff' in non-chroot builds.
  NROFF = "${groff}/bin/nroff";

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-widec"
  ];

  meta = with stdenv.lib; {
    homepage = "http://www.thrysoee.dk/editline/";
    description = "A port of the NetBSD Editline library (libedit)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
