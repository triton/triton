{ stdenv
, fetchurl
, intltool
, lib
, procps

, dbus-glib
, glib
, gtk
, kmod
, libsecret
, networkmanager
, networkmanager-applet
, vpnc

, findHardcodedPaths ? false  # for derivation testing only

, channel
}:

let
  inherit (lib)
    boolWt
    optionalString;

  sources = {
    "1.2" = {
      version = "1.2.4";
      sha256 = "39c7516418e90208cb534c19628ce40fd50eba0a08b2ebaef8da85720b10fb05";
    };
  };
  source = sources."${channel}";
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
    gtk
    libsecret
    networkmanager
    networkmanager-applet
    vpnc
  ];

  preConfigure = ''
    sed -i configure \
      -e 's,/sbin/sysctl,${procps}/bin/sysctl,g'
    sed -i src/nm-vpnc-service.c \
      -e 's,/sbin/vpnc,${vpnc}/bin/vpnc,g' \
      -e 's,/sbin/modprobe,${kmod}/bin/modprobe,g'
    sed -i properties/nm-vpnc-editor-plugin.c \
      -e 's,/usr.*/cisco-decrypt,${vpnc}/bin/cisco-decrypt,g'
  '' + optionalString findHardcodedPaths ''
    rm -rf build-aux ChangeLog config.{guess,sub} configure{,.ac} ltmain.sh m4/ man/ docs/ INSTALL *.m4
    grep -rP '^(?!#!).*/(usr|bin|sbin).*'; return 1
  '';

  configureFlags = [
    "--enable-maintainer-mode"
    #"--enable-absolute-paths"
    "--enable-nls"
    "--enable-more-warnings"
    "--${boolWt (
      gtk != null
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
