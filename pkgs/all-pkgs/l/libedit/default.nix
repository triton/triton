{ stdenv
, fetchurl
, groff

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20170329-3.1";

  src = fetchurl {
    url = "http://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmULcVDrdQJZ8rpjkFveL3zqfhQw5Mg5XM8EMzuWvKeuCk";
    sha256 = "91f2d90fbd2a048ff6dad7131d9a39e690fd8a8fd982a353f1333dd4017dd4be";
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
    homepage = "http://thrysoee.dk/editline/";
    description = "A port of the NetBSD Editline library (libedit)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
