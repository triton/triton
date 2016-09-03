{ stdenv
, fetchurl
, intltool
, python

, dbus
, dbus-glib
, glib
, gobject-introspection
, xorg

, channel
}:

assert xorg != null ->
  xorg.libSM != null
  && xorg.libX11 != null
  && xorg.libXi != null
  && xorg.libXtst != null;

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "at-spi2-core-${source.version}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/at-spi2-core/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/at-spi2-core/${channel}/"
      + "${name}.sha256sum";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
    python
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gobject-introspection
    xorg.inputproto
    xorg.kbproto
    xorg.xproto
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libXtst
  ];

  configureFlags = [
    "--enable-nls"
    (enFlag "x11" (xorg != null) null)
    # xevie is deprecated/broken since xorg-1.6/1.7
    "--disable-xevie"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "x" (xorg != null) null)
    "--with-dbus-daemondir=/run/current-system/sw/bin/"
  ];

  meta = with stdenv.lib; {
    description = "D-Bus accessibility specifications and registration daemon";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
