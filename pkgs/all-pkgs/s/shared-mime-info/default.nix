{ stdenv
, fetchurl
, gettext
, intltool
, lib
, perl

, glib
, libxml2
}:

stdenv.mkDerivation rec {
  name = "shared-mime-info-1.10";

  src = fetchurl {
    url = "https://freedesktop.org/~hadess/${name}.tar.xz";
    multihash = "QmcuVe36fVrVZQvMcqaj2X1ipL2Qrt56DTYDD1b1PCUWBK";
    sha256 = "c625a83b4838befc8cafcd54e3619946515d9e44d63d61c4adf7f5513ddfbebf";
  };

  nativeBuildInputs = [
    gettext
    intltool
    perl
  ];

  buildInputs = [
    glib
    libxml2
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-update-mimedb"
  ];

  preFixup = ''
    $out/bin/update-mime-database -V $out/share/mime
  '';

  doCheck = true;
  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    description = "The Shared MIME-info Database specification";
    homepage = https://freedesktop.org/wiki/Software/shared-mime-info;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
