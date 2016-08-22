{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.4.0";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "59769deddef02acd60db3a42d772e57bd0978efb";
    multihash = "QmWqYN94wgrrAoEey9gvr3pPXmUmTpDveU2jywdqkkt1pa";
    sha256 = "b8518ca88acfcbc474a406022ee9c0c3210ccef4f0ec80e5b3e8c41dda8c16f2";
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
