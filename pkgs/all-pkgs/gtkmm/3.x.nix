{ stdenv
, fetchurl

, atkmm
, cairomm
, epoxy
, gdk-pixbuf
, glibmm
, gtk3
, pangomm
}:

stdenv.mkDerivation rec {
  name = "gtkmm-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${versionMajor}/${name}.tar.xz";
    sha256 = "0sxq700invkjpksn790gbnl8px8751kvgwn39663jx7dv89s37w2";
  };

  configureFlags = [
    "--disable-quartz-backend"
    "--enable-x11-backend"
    "--enable-wayland-backend"
    "--enable-brodway-backend"
    "--enable-api-atkmm"
    # Requires glibmm deprecated api
    "--enable-deprecated-api"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-cairomm-doc"
    "--without-pangomm-doc"
    "--without-atkmm-doc"
  ];

  buildInputs = [
    atkmm
    cairomm
    epoxy
    gdk-pixbuf
    glibmm
    gtk3
    pangomm
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ interface for GTK+";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
