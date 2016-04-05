{ stdenv
, fetchurl
, gettext
, libtool

, ncurses
}:

stdenv.mkDerivation rec {
  name = "dialog-${version}";
  version = "1.3-20160209";

  src = fetchurl {
    url = "ftp://invisible-island.net/dialog/${name}.tgz";
    allowHashOutput = false;
    sha256 = "0314f7f2195edc58e7567a024dc1d658c2f8ea732796d8fa4b4927df49803f87";
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
    sourceTarball = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyId = "F7E48EDB";
      pgpKeyFingerprint = "C520 48C0 C074 8FEE 227D  47A2 7023 53E0 F7E4 8EDB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://invisible-island.net/dialog/dialog.html;
    description = "Display dialog boxes from shell";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
