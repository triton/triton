{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.5.7";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "ba45b9c6f6acff756fba70e4819f259bb0c3f1bc";
    multihash = "QmSEq6QCbtLjVmuGFA2ih3BRNscQ2v14TKC1hqd91x8Lsk";
    sha256 = "4a38efaa0ca85ee5484d046bd427012979264fef17f07fd7855860e592819482";
  };

  nativeBuildInputs = [
    gettext
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
