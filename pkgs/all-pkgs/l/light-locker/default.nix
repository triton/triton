{ stdenv
, fetchurl
, gettext
, glib
, intltool
, lib
, makeWrapper
, perl

, dbus
, dbus-glib
, dconf
, gdk-pixbuf
, gtk_3
, libice
, libsm
, libx11
, libxext
, libxscrnsaver
, systemd_lib
, xorg
, xorgproto
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "light-locker-${version}";

  src = fetchurl {
    url = "https://github.com/the-cavalry/light-locker/releases/download/v${version}/${name}.tar.bz2";
    sha256 = "3c76106f40a8efe67b462061e4c798e3e501b54356c8cdc1b67a3022d9d7dba1";
  };

  nativeBuildInputs = [
    gettext
    glib
    intltool
    makeWrapper
    perl
  ];

  buildInputs = [
    dbus
    dbus-glib
    dconf
    glib
    gtk_3
    libice
    libsm
    libx11
    libxext
    libxscrnsaver
    xorg.libXxf86misc
    xorg.libXxf86vm
    systemd_lib
    xorgproto
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  preFixup = ''
    wrapProgram $out/bin/light-locker \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES"
  '';

  meta = with lib; {
    description = "LightDM Locker";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
