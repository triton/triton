{ stdenv
, fetchurl
, gettext
, libtool

, ncurses
}:

stdenv.mkDerivation rec {
  name = "dialog-1.3-20160828";

  src = fetchurl {
    url = "ftp://invisible-island.net/dialog/${name}.tgz";
    hashOutput = false;
    sha256 = "453095abaec288bfbc1ca9faced917e17742cff1ea45ec46210071ac153562f9";
  };

  nativeBuildInputs = [
    libtool
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--disable-rpath-hacks"
    "--with-libtool"
    "--with-libtool-opts=-shared"
    "--with-ncursesw"
  ];

  installTargets = [
    "install-full"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "C520 48C0 C074 8FEE 227D  47A2 7023 53E0 F7E4 8EDB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Display dialog boxes from shell";
    homepage = http://invisible-island.net/dialog/dialog.html;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
