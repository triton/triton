{ stdenv
, fetchurl
, gettext
, intltool

, glib
, libxml2
}:

stdenv.mkDerivation rec {
  name = "shared-mime-info-1.7";

  src = fetchurl {
    url = "https://freedesktop.org/~hadess/${name}.tar.xz";
    sha256 = "eacc781cfebaa2074e43cf9521dc7ab4391ace8a4712902b2841669c83144d2e";
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
  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "The Shared MIME-info Database specification";
    homepage = http://freedesktop.org/wiki/Software/shared-mime-info;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
