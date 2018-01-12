{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, libxml2
}:

stdenv.mkDerivation rec {
  name = "shared-mime-info-1.9";

  src = fetchurl {
    url = "https://freedesktop.org/~hadess/${name}.tar.xz";
    multihash = "QmRuSuazf3cvmybato9Ks23rGLEpT4KXEryPPAPDCAEuyD";
    sha256 = "5c0133ec4e228e41bdf52f726d271a2d821499c2ab97afd3aa3d6cf43efcdc83";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    libxml2
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-default-make-check"
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
