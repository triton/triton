{ stdenv, fetchurl, musl
, enableStatic ? false
, enableMinimal ? false
, useMusl ? false
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
  name = "busybox-1.24.2";

  src = fetchurl {
    urls = [
      "http://sources.openelec.tv/mirror/busybox/${name}.tar.bz2"
      "https://busybox.net/downloads/${name}.tar.bz2"
    ];
    md5Urls = map (n: "${n}.md5") src.urls;
    sha256 = "e71ef53ec656f31c42633918d301405d40dea1d97eca12f272217ae4a971c855";
  };

  patches = [ ./busybox-in-store.patch ];

  configurePhase = ''
    export KCONFIG_NOTIMESTAMP=1
    make ${if enableMinimal then "allnoconfig" else "defconfig"}

    ${configParser}

    cat << EOF | parseconfig

    CONFIG_PREFIX "$out"
    CONFIG_INSTALL_NO_USR y

    CONFIG_LFS y

    ${stdenv.lib.optionalString enableStatic ''
      CONFIG_STATIC y
    ''}

    # Use the external mount.cifs program.
    CONFIG_FEATURE_MOUNT_CIFS n
    CONFIG_FEATURE_MOUNT_HELPERS y

    ${extraConfig}
    $extraCrossConfig
    EOF

    make oldconfig
  '' + stdenv.lib.optionalString useMusl ''
    makeFlagsArray+=("CC=gcc -isystem ${musl}/include -B${musl}/lib -L${musl}/lib")
  '';

  crossAttrs = {
    extraCrossConfig = ''
      CONFIG_CROSS_COMPILER_PREFIX "${stdenv.cross.config}-"
    '' +
      (if stdenv.cross.platform.kernelMajor == "2.4" then ''
        CONFIG_IONICE n
      '' else "");
  };

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Tiny versions of common UNIX utilities in a single small executable";
    homepage = http://busybox.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ viric ];
    platforms = platforms.linux;
    priority = 9;  # Lower than everything but lowPrio packages
  };
}
