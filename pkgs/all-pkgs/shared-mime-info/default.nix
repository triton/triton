{ stdenv
, fetchurl
, gettext
, intltool

, glib
, libxml2
}:

stdenv.mkDerivation rec {
  name = "shared-mime-info-1.6";

  src = fetchurl {
    url = "http://freedesktop.org/~hadess/${name}.tar.xz";
    sha256 = "b2f8f85b6467933824180d0252bbcaee523f550a8fbc95cc4391bd43c03bc34c";
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
