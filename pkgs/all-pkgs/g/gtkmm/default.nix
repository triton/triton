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

  sources = {
    "3.24" = {
      version = "3.24.1";
      sha256 = "ddfe42ed2458a20a34de252854bcf4b52d3f0c671c045f56b42aa27c7542d2fd";
    };
  };
  source = sources."${channel}";
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
    "--enable-api-atkmm"
    # Requires deprecated api to build
    #"--enable-deprecated-api"
    "--enable-warnings"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gtkmm/${channel}/"
          + "${name}.sha256sum";
      };
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
