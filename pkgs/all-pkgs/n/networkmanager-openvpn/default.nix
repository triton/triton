{ stdenv
, fetchurl
, gettext
, intltool
, kmod
, lib
, procps

, dbus-glib
, glib
, gtk
, libsecret
, networkmanager
, networkmanager-applet
, openvpn

, findHardcodedPaths ? false  # for derivation testing only

, channel
}:

let
  inherit (lib)
    boolWt
    optionalString;

  sources = {
    "1.8" = {
      version = "1.8.0";
      sha256 = "166e1123ade1b322162b83876c605393a8e74240aa908cba934319f312b2e3a4";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-openvpn-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-openvpn/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus-glib
    glib
    gtk
    libsecret
    networkmanager
    networkmanager-applet
    openvpn
  ];

  postPatch = ''
    sed -i configure \
      -e 's,/sbin/sysctl,${procps}/sbin/sysctl,g'
    sed -i src/nm-openvpn-service.c \
      -e 's,/sbin/openvpn,${openvpn}/sbin/openvpn,g' \
      -e 's,/sbin/modprobe,${kmod}/sbin/modprobe,g'
    sed -i properties/auth-helpers.c \
      -e 's,/sbin/openvpn,${openvpn}/sbin/openvpn,g'
  '' + optionalString findHardcodedPaths ''
    rm -rf build-aux config.{guess,sub} configure{,.ac} ltmain.sh m4/ man/ docs INSTALL *.m4
    grep -rP '^(?!#!).*/(usr|bin|sbin).*'; return 1
  '';

  configureFlags = [
    "--localstatedir=/"
    "--disable-maintainer-mode"
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
      sha256Url = "https://download.gnome.org/sources/NetworkManager-openvpn/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "NetworkManager OpenVPN plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
