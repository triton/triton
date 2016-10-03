{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib

, dbus-glib
, glib
, gtk_3
, libgnome-keyring
, libsecret
, networkmanager
, networkmanager-applet
, ppp
, pptp

, channel
}:

let
  inherit (lib)
    boolWt;

  source = (import ./sources.nix { })."${channel}";
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
    gtk_3
    libsecret
    networkmanager
    networkmanager-applet
    ppp
    pptp
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/pptp-purity.patch";
      sha256 = "8d3359767c1acb8cf36eff094763b8f9ce0a860e2b20f585e0922ee2c4750c23";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    #"--enable-absolute-paths"
    "--enable-nls"
    "--enable-more-warnings"
    #"--with-pppd-plugin-dir"
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
