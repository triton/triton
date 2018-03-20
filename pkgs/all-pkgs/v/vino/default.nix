{ stdenv
, fetchurl
, intltool
, makeWrapper

, adwaita-icon-theme
, avahi
, dbus-glib
, dconf
, file
, glib
, gnutls
, gtk
, libgcrypt
, libice
, libjpeg
, libnotify
, libsecret
, libsm
, libsoup
, libx11
, libxext
, libxtst
, telepathy_glib
, xorgproto
, zlib

, channel
}:

let
  inherit (stdenv.lib)
    boolWt
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "vino-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vino/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    avahi
    dbus-glib
    dconf
    file
    glib
    gnutls
    gtk
    libgcrypt
    libice
    libjpeg
    libnotify
    libsecret
    libsm
    libsoup
    libx11
    libxext
    libxtst
    telepathy_glib
    xorgproto
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--enable-nls"
    "--enable-ipv6"
    "--enable-schemas-compile"
    "--${boolWt (telepathy_glib != null)}-telepathy"
    "--${boolWt (libsecret != null)}-secret"
    "--${boolWt (libx11 != null)}-x"
    "--${boolWt (gnutls != null)}-gnutls"
    "--${boolWt (libgcrypt != null)}-gcrypt"
    "--${boolWt (avahi != null)}-avahi"
    "--${boolWt (zlib != null)}-zlib"
    "--${boolWt (libjpeg != null)}-jpeg"
  ];

  preFixup = ''
    wrapProgram $out/libexec/vino-server \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/vino/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "GNOME desktop sharing server";
    homepage = https://wiki.gnome.org/action/show/Projects/Vino;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
