{ stdenv
, fetchurl
, gettext
, glib
, intltool
, lib
, perl

, dbus
, dbus-glib
, gtk3
, libice
, libsm
, libx11
, libxext
, libxscrnsaver
, systemd_lib
, scrnsaverproto
, xextproto
, xf86miscproto
, xf86vidmodeproto
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
    perl
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gtk3
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

  meta = with lib; {
    description = "LightDM Locker";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
