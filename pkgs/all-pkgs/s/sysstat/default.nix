{ stdenv
, fetchurl
, gettext

, lm-sensors
}:

stdenv.mkDerivation rec {
  name = "sysstat-12.3.1";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    multihash = "QmdCd8KuM1JMadoM85TDfjckvbF8KMb73E7p9E7SVqXfVB";
    hashOutput = false;
    sha256 = "7865c6bfbfc84923976801d5b1dc07db27e26f670c37b5d5ab2be6a98ed7c1c1";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    lm-sensors
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "conf_dir=/etc"
      "man_group=$(id -g -n)"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "SYSCONFIG_DIR=$out/etc"
      "SA_DIR=$TMPDIR/var"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Confirm = "c71d27faffd05198beb1005f1d0a2632666a37ca";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://sebastien.godard.pagesperso-orange.fr/;
    description = "A collection of performance monitoring tools for Linux (such as sar, iostat and pidstat)";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
