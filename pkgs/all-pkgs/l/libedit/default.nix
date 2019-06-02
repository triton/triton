{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20190324-3.1";

  src = fetchurl {
    url = "https://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmZ5jhgAtHZYBTnwDgMXQ3FYbSa4iDXYwGrx29j81DoAu6";
    sha256 = "ac8f0f51c1cf65492e4d1e3ed2be360bda41e54633444666422fbf393bba1bae";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    homepage = "https://thrysoee.dk/editline/";
    description = "A port of the NetBSD Editline library (libedit)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
