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
  && xorg.libXtst != null
  && xorg.xextproto != null;

let
  inherit (stdenv.lib)
    boolEn
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "at-spi2-core-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-core/${channel}/${name}.tar.xz";
    hashOutput = false;
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
    xorg.xextproto
  ];

  configureFlags = [
    "--enable-nls"
    "--${boolEn (xorg != null)}-x11"
    # xevie is deprecated/broken since xorg-1.6/1.7
    "--disable-xevie"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (xorg != null)}-x"
    "--with-dbus-daemondir=/run/current-system/sw/bin/"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/at-spi2-core/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

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
