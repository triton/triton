{ stdenv
, fetchurl
, gettext
, intltool
, lib
, perl

, glib
, gtk_2
, gtk_3
, libxfce4util
, xfconf
, xorg

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libxfce4ui-${source.version}";

  src = fetchurl ({
    url = "http://archive.xfce.org/src/xfce/libxfce4ui/${channel}/"
      + "${name}.tar.bz2";
    hashOutput = false;
    inherit (source) multihash sha256;
  });

  nativeBuildInputs = [
    gettext
    intltool
    perl
  ];

  buildInputs = [
    glib
    gtk_2
    gtk_3
    libxfce4util
    xfconf
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.xproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (gtk_3 != null)}-gtk3"
    "--enable-startup-notification"
    "--enable-keyboard-library"
    "--enable-gladeui"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-debug"
    #"--disable-linker-opts"
    #"--disable-visibility"
    "--with-x"
  ];

  meta = with lib; {
    description = "Unified widgets and session management libraries";
    homepage = http://www.xfce.org/projects/libxfce4;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
