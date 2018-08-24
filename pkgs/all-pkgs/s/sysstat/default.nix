{ stdenv
, fetchurl
, gettext

, lm-sensors
}:

stdenv.mkDerivation rec {
  name = "sysstat-12.0.1";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    multihash = "QmXbfQWjoxNz7LCo3sPhbEqhePFpyz6wQ2iVFJo8ZEUanS";
    hashOutput = false;
    sha256 = "a1bc554e2ab81ed4f7443ba0c7c572e90853fc786d588ebe024ca088e3819c84";
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
        sha1Confirm = "5bb0000f838e744c306f7bb826c5ca41040c7297";
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
