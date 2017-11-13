{ stdenv
, fetchurl
, gettext
, intltool
, kmod
, lib
, procps

, dbus-glib
, glib
, gtk_3
, libsecret
, libxml2
, networkmanager
, openconnect

, channel
}:

let
  inherit (lib)
    boolWt;

  sources = {
    "1.2" = {
      version = "1.2.4";
      sha256 = "a177e0cf683b63e225ecc08049a1d57f05868b5660f0907c65d5ecab39474996";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-openconnect-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-openconnect/${channel}/"
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
    gtk_3
    libsecret
    libxml2
    networkmanager
    openconnect
  ];

  preConfigure = ''
    sed -i configure \
      -e 's,/sbin/sysctl,${procps}/sbin/sysctl,g'
    sed -i src/nm-openconnect-service.c \
      -e 's,/usr/sbin/openconnect,${openconnect}/sbin/openconnect,g' \
      -e 's,/sbin/modprobe,${kmod}/sbin/modprobe,g'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    #"--enable-absolute-paths"
    "--enable-nls"
    "--enable-more-warnings"
    "--${boolWt (
      gtk_3 != null
      && libsecret != null)}-gnome"
    "--with-libnm-glib"
    "--${boolWt (
      gtk_3 != null
      && libsecret != null
      && openconnect != null)}-authdlg"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/"
        + "NetworkManager-openconnect/${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "NetworkManager OpenConnect plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
