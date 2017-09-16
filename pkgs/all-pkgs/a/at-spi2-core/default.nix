{ stdenv
, fetchurl
, intltool
, lib
, python

, dbus
, dbus-glib
, glib
, gobject-introspection
, inputproto
, kbproto
, libsm
, libice
, libx11
, libxi
, xextproto
, xorg
, xproto

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "2.26" = {
      version = "2.26.0";
      sha256 = "511568a65fda11fdd5ba5d4adfd48d5d76810d0e6ba4f7460f1b2ec0dbbbc337";
    };
  };
  source = sources."${channel}";
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
    inputproto
    kbproto
    xproto
    libsm
    libx11
    libxi
    xorg.libXtst
    xextproto
  ];

  configureFlags = [
    "--enable-nls"
    "--${boolEn (libx11 != null)}-x11"
    # xevie is deprecated/broken since xorg-1.6/1.7
    "--disable-xevie"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (libx11 != null)}-x"
    "--with-dbus-daemondir=/run/current-system/sw/bin/"
    #"--with-dbus-services="
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

  meta = with lib; {
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
