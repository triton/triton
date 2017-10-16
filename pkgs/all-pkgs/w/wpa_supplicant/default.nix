{ stdenv
, fetchTritonPatch
, fetchurl
, writeText

, dbus
, libnl
, ncurses
, openssl
, pcsc-lite_lib
, readline
}:

let
  version = "2.6";

  inherit (stdenv.lib)
    optionals
    optionalString
    versionAtLeast;

  # TODO: Patch epoll so that the dbus actually responds
  # TODO: Figure out how to get privsep working, currently getting SIGBUS
  extraConfigFile = writeText "wpa_supplicant-config" (''
    CONFIG_AP=y
    CONFIG_LIBNL32=y
    CONFIG_EAP_FAST=y
    CONFIG_EAP_PWD=y
    CONFIG_EAP_PAX=y
    CONFIG_EAP_SAKE=y
    CONFIG_EAP_GPSK=y
    CONFIG_EAP_GPSK_SHA256=y
    CONFIG_WPS=y
    CONFIG_WPS_ER=y
    CONFIG_WPS_NFS=y
    CONFIG_EAP_IKEV2=y
    CONFIG_EAP_EKE=y
    CONFIG_HT_OVERRIDES=y
    CONFIG_VHT_OVERRIDES=y
    CONFIG_ELOOP=eloop
    #CONFIG_ELOOP_EPOLL=y
    CONFIG_L2_PACKET=linux
    CONFIG_IEEE80211W=y
    CONFIG_TLS=openssl
    CONFIG_TLSV11=y
    CONFIG_TLSV12=y
    CONFIG_IEEE80211R=y
    CONFIG_DEBUG_SYSLOG=y
    #CONFIG_PRIVSEP=y
    CONFIG_IEEE80211N=y
    CONFIG_IEEE80211AC=y
    CONFIG_INTERNETWORKING=y
    CONFIG_HS20=y
    CONFIG_P2P=y
    CONFIG_TDLS=y
  '' + optionalString (pcsc-lite_lib != null) ''
    CONFIG_EAP_SIM=y
    CONFIG_EAP_AKA=y
    CONFIG_EAP_AKA_PRIME=y
    CONFIG_PCSC=y
  '' + optionalString (dbus != null) ''
    CONFIG_CTRL_IFACE_DBUS=y
    CONFIG_CTRL_IFACE_DBUS_NEW=y
    CONFIG_CTRL_IFACE_DBUS_INTRO=y
  '' + (if readline != null then ''
    CONFIG_READLINE=y
  '' else ''
    CONFIG_WPA_CLI_EDIT=y
  ''));

in
stdenv.mkDerivation rec {
  name = "wpa_supplicant-${version}";

  src = fetchurl {
    url = "https://w1.fi/releases/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b4936d34c4e6cdd44954beba74296d964bc2c9668ecaa5255e499636fe2b1450";
  };

  patches = [
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0001-hostapd-Avoid-key-reinstallation-in-FT-handshake.patch";
      sha256 = "529113cc81256c6178f3c1cf25dd8d3f33e6d770e4a180bd31c6ab7e4917f40b";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0002-Prevent-reinstallation-of-an-already-in-use-group-ke.patch";
      sha256 = "d86d47ab74170f3648b45b91bce780949ca92b09ab43df065178850ec0c335d7";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0003-Extend-protection-of-GTK-IGTK-reinstallation-of-WNM-.patch";
      sha256 = "d4535e36739a0cc7f3585e6bcba3c0bb8fc67cb3e729844e448c5dc751f47e81";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0004-Prevent-installation-of-an-all-zero-TK.patch";
      sha256 = "793a54748161b5af430dd9de4a1988d19cb8e85ab29bc2340f886b0297cee20b";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0005-Fix-PTK-rekeying-to-generate-a-new-ANonce.patch";
      sha256 = "147c8abe07606905d16404fb2d2c8849796ca7c85ed8673c09bb50038bcdeb9e";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0006-TDLS-Reject-TPK-TK-reconfiguration.patch";
      sha256 = "596d4d3b63ea859ed7ea9791b3a21cb11b6173b04c0a14a2afa47edf1666afa6";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0007-WNM-Ignore-WNM-Sleep-Mode-Response-without-pending-r.patch";
      sha256 = "c5a17af84aec2d88c56ce0da2d6945be398fe7cab5c0c340deb30973900c2736";
    })
    (fetchTritonPatch {
      rev = "dc847f050bc48a6f589efae3aed0bf8279195f30";
      file = "w/wpa_supplicant/rebased-v2.6-0008-FT-Do-not-allow-multiple-Reassociation-Response-fram.patch";
      sha256 = "c8840d857b9432f3b488113c85c1ff5d4a4b8d81078b7033388dae1e990843b1";
    })
  ] ++ optionals (versionAtLeast openssl.version "1.1.0") [
    (fetchTritonPatch {
      rev = "01c6bdc70a6e1f37438e98777b9e645d5e6f994b";
      file = "w/wpa_supplicant/fix-pem-decryption.patch";
      sha256 = "849444bd27390b00386a237941bcf3f3a0c429528445580148a919e08a58187d";
    })
  ];

  buildInputs = [
    dbus
    libnl
    ncurses
    openssl
    pcsc-lite_lib
    readline
  ];

  preBuild = ''
    cd wpa_supplicant
    cp -v defconfig .config
    cat '${extraConfigFile}' >> .config
    cat -n .config

    sed -i "s,/usr/local,$out,g" Makefile

    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE \
      -I$(echo "${libnl}"/include/libnl*/) \
      -I${pcsc-lite_lib}/include/PCSC/"
  '';

  postInstall = ''
    mkdir -p $out/share/man/man5 $out/share/man/man8
    cp -v "doc/docbook/"*.5 $out/share/man/man5/
    cp -v "doc/docbook/"*.8 $out/share/man/man8/
    mkdir -p $out/etc/dbus-1/system.d $out/share/dbus-1/system-services $out/etc/systemd/system
    cp -v "dbus/"*service $out/share/dbus-1/system-services
    sed -e "s@/sbin/wpa_supplicant@$out&@" -i "$out/share/dbus-1/system-services/"*
    cp -v dbus/dbus-wpa_supplicant.conf $out/etc/dbus-1/system.d
    cp -v "systemd/"*.service $out/etc/systemd/system
    rm $out/share/man/man8/wpa_priv.8
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "EC4A A0A9 91A5 F246 4582  D52D 2B6E F432 EFC8 95FA";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://hostap.epitest.fi/wpa_supplicant/;
    description = "A tool for connecting to WPA and WPA2-protected wireless networks";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
