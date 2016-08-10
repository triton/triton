{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.3.5";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "211cfb74e3cf2df98a59e4f7f3e7aea9684a5ff9";
    multihash = "QmemsEgnvjrH5cGuWVcKjRdKn3mc3EkmssBDPSXB7TzAxL";
    sha256 = "aa06ab8132d618ed7737346ac882732d54c9f2956f6ab3c9d36657c5e1923709";
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
