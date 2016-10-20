{ stdenv
, fetchurl
, gettext
, intltool
, lib

, dbus
, dbus-glib
, glib
, libxfce4util

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "xfconf-${source.version}";

  src = fetchurl {
    url = "http://archive.xfce.org/src/xfce/xfconf/${channel}/${name}.tar.bz2";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    libxfce4util
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-perl-bindings"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-debug"
    "--enable-checks"
    #"--disable-visibility"
    #"--disable-linker-opts"
    "--disable-profiling"
  ];

  meta = with lib; {
    description = "A simple client-server configuration storage and query system";
    homepage = http://www.xfce.org/projects/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
