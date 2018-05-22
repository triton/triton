{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, minimal ? false
, extraConfig ? ""
}:

let
  inherit (lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "busybox-1.28.4";

  src = fetchurl {
    urls = [
      "https://busybox.net/downloads/${name}.tar.bz2"
      "http://sources.openelec.tv/mirror/busybox/${name}.tar.bz2"
    ];
    hashOutput = false;
    sha256 = "e3c14a3699dc7e82fed397392957afc78e37bdf25398ac38ead6e84621b2ae6a";
  };

  patches = [
    (fetchTritonPatch {
      rev = "40c0f9e7aac6a37d209bbf77b656ac158124aaa1";
      file = "b/busybox/in-store.patch";
      sha256 = "608387a9cfa8dfa80b22f21612aeb89c90fbf395983544c9763b8b82e3f79fb5";
    })
  ];

  configurePhase = ''
    export KCONFIG_NOTIMESTAMP=1
    make ${if minimal then "allnoconfig" else "defconfig"}

    parseconfig() {
      while read LINE; do
        NAME=`echo "$LINE" | cut -d \  -f 1`
        OPTION=`echo "$LINE" | cut -d \  -f 2`

        if ! [[ "$NAME" =~ ^CONFIG_ ]]; then continue; fi

        echo "parseconfig: removing $NAME"
        sed -i /$NAME'\(=\| \)'/d .config

        echo "parseconfig: setting $NAME=$OPTION"
        echo "$NAME=$OPTION" >> .config
      done
    }

    cat << EOF | parseconfig

    CONFIG_LFS y
    CONFIG_PREFIX "$out"
    CONFIG_PID_FILE_PATH="/run"
    CONFIG_INSTALL_NO_USR y

    ${optionalString (!minimal) ''
      # Use the external mount.cifs program.
      CONFIG_FEATURE_MOUNT_CIFS n
      CONFIG_FEATURE_MOUNT_HELPERS y
    ''}

    ${extraConfig}
    EOF

    make oldconfig
  '';

  postInstall = ''
    mkdir -p "$out"/share/busybox
    cp .config "$out"/share/busybox/config
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}.sign") src.urls;
      pgpKeyFingerprint = "C9E9 416F 76E6 10DB D09D  040F 47B7 0C55 ACC9 965B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tiny versions of common UNIX utilities in a single small executable";
    homepage = http://busybox.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
    priority = 9;  # Lower than everything but lowPrio packages
  };
}
