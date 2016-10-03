{ stdenv
, fetchurl
, intltool
, kmod
, lib
, procps

, dbus-glib
, glib
, gtk_3
, libsecret
, networkmanager
, networkmanager-applet
, vpnc

, channel
}:

let
  inherit (lib)
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-vpnc-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-vpnc/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    dbus-glib
    glib
    gtk_3
    libsecret
    networkmanager
    networkmanager-applet
    vpnc
  ];

  preConfigure = ''
    sed -i configure \
      -e 's,/sbin/sysctl,${procps}/sbin/sysctl,g'
    sed -i src/nm-vpnc-service.c \
      -e 's,/sbin/vpnc,${vpnc}/sbin/vpnc,g' \
      -e 's,/sbin/modprobe,${kmod}/sbin/modprobe,g'
  '';

  configureFlags = [
    "--enable-maintainer-mode"
    #"--enable-absolute-paths"
    "--enable-nls"
    "--enable-more-warnings"
    "--${boolWt (
      gtk_3 != null
      && networkmanager-applet != null
      && libsecret != null)}-gnome"
    "--with-libnm-glib"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/NetworkManager-vpnc/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "NetworkManager VPNC plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
