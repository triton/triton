{ stdenv
, fetchTritonPatch
, fetchurl

, static ? false
, minimal ? false
, extraConfig ? ""
}:

let
  configParser = ''
    function parseconfig {
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
  '';
in
stdenv.mkDerivation rec {
  name = "busybox-1.28.1";

  src = fetchurl {
    urls = [
      "https://busybox.net/downloads/${name}.tar.bz2"
      "http://sources.openelec.tv/mirror/busybox/${name}.tar.bz2"
    ];
    hashOutput = false;
    sha256 = "98fe1d3c311156c597cd5cfa7673bb377dc552b6fa20b5d3834579da3b13652e";
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

    ${configParser}

    cat << EOF | parseconfig

    CONFIG_PREFIX "$out"
    CONFIG_INSTALL_NO_USR y

    CONFIG_LFS y

    ${stdenv.lib.optionalString static ''
      CONFIG_STATIC y
    ''}

    # Use the external mount.cifs program.
    CONFIG_FEATURE_MOUNT_CIFS n
    CONFIG_FEATURE_MOUNT_HELPERS y

    ${extraConfig}
    $extraCrossConfig
    EOF

    make oldconfig
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
      i686-linux
      ++ x86_64-linux;
    priority = 9;  # Lower than everything but lowPrio packages
  };
}
