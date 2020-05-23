{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20191231-3.1";

  src = fetchurl {
    url = "https://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmVGzfVwWzsbb3ScZsreMxEpsVsWwQvXhrrc4gTe28PPVt";
    sha256 = "dbb82cb7e116a5f8025d35ef5b4f7d4a3cdd0a3909a146a39112095a2d229071";
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
