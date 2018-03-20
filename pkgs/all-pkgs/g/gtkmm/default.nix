{ stdenv
, fetchurl
, lib

, atkmm
, cairomm
, gdk-pixbuf
, glibmm
, gtk
, libepoxy
, pangomm

, channel
}:

/*
  To generate files from source:

  nativeBuildInputs = [
    autoreconfHook
    gnum4
    mm-common
    perlPackages.perl
    perlPackages.XMLParser
  ]

  preAutoreconf = ''
    mm-common-prepare --copy --force .
  '';

  # Codegen directories are not added to sources unless enabled.
  configureFlags = [
    "--enable-maintainer-mode"
  ];
*/

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gtkmm-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    atkmm
    cairomm
    gdk-pixbuf
    glibmm
    gtk
    libepoxy
    pangomm
  ];

  postPatch = ''
    sed -i gdk/gdkmm/window.h \
      -i gdk/gdkmm/window.cc \
      -e 's/::Cairo::Format/::Cairo::Surface::Format/g'
  '';

  preConfigure = ''
    sed -i configure \
      -e 's/cairomm-1.0/cairomm-1.16/g'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--${boolEn gtk.x11_backend}-x11-backend"
    "--${boolEn gtk.wayland_backend}-wayland-backend"
    "--${boolEn gtk.broadway_backend}-broadway-backend"
    "--${boolEn (atkmm != null)}-api-atkmm"
    # Requires deprecated api to build
    "--enable-deprecated-api"
    "--disable-documentation"
    "--enable-warnings"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
    "--without-pangomm-doc"
    "--without-atkmm-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gtkmm/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "C++ interface for GTK+";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
