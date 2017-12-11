{ stdenv
, fetchurl
, gettext
, libtool

, ncurses
}:

stdenv.mkDerivation rec {
  name = "dialog-1.3-20171209";

  src = fetchurl {
    url = "https://invisible-mirror.net/archives/dialog/${name}.tgz";
    multihash = "QmRGktegXLbQ5VK4ryaYwQXWw5N1KViLZjQduPCVoxr7av";
    hashOutput = false;
    sha256 = "20139442119e2eff5c35236e8e5e313c901539008d9cccf8c8ab3851b41267e6";
  };

  nativeBuildInputs = [
    libtool
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--with-libtool"
    "--with-shared"
    "--enable-rpath"
    "--with-ncursesw"
    "--disable-rpath-hacks"
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
