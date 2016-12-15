{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.5.3";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "01682732020ef6b463f7aab87aa9650147f71744";
    multihash = "QmX9PXQK5XK42ToGDByr2k2uzuNK1GJwRakvWjC1TdkpDj";
    sha256 = "f8229d14819e2d461ede83894648e03c8a2ad14a1ba200d68cda9816c42f41ea";
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
