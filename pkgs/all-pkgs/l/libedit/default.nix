{ stdenv
, fetchurl
, groff

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20160903-3.1";

  src = fetchurl {
    url = "http://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmNmfgvb2fhGc6NvSoPg7RYtvpURzPhAqyuQmAJjZWJbJH";
    sha256 = "0ccbd2e7d46097f136fcb1aaa0d5bc24e23bb73f57d25bee5a852a683eaa7567";
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
