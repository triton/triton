{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib

, dbus-glib
, glib
, gtk
, libgnome-keyring
, libsecret
, networkmanager
, networkmanager-applet
, ppp
, pptp

, findHardcodedPaths ? false  # for derivation testing only

, channel
}:

let
  inherit (lib)
    boolWt
    optionalString;

  sources = {
    "1.2" = {
      version = "1.2.6";
      sha256 = "c3292ec8769c391f9179e5aa74d01c2bbb697c91598e9485ac2e97fafc4745b4";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-pptp-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-pptp/${channel}/"
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
    ppp
    pptp
  ];

  postPatch = /* Fix hardcoded/impure paths */ ''
    # FIXME IMPURE: modprobe uses an impure path
    sed -i src/nm-pptp-service.c \
      -e 's,/\(sbin\|usr\).*/pppd,${ppp}/bin/pppd,g' \
      -e 's,/\(sbin\|usr\).*/pptp,${pptp}/bin/pptp,g' \
      -e 's,/sbin/modprobe,/run/current-system/sw/bin/modprobe,'
  '' + optionalString findHardcodedPaths ''
    rm -rf build-aux config.{guess,sub} configure{,.ac} ltmain.sh m4/ man/ docs/ INSTALL *.m4
    grep -rP '^(?!#!).*/(usr|bin|sbin).*'; return 1
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    #"--enable-absolute-paths"
    "--enable-nls"
    "--enable-more-warnings"
    #"--with-pppd-plugin-dir"
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
      sha256Url = "https://download.gnome.org/sources/NetworkManager-pptp/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "NetworkManager PPTP plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
