{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.5.5";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "30929b7c92ab2e1e66906ed084d068398148eb78";
    multihash = "QmZqJiSF5At3MU51iQkUbyVLN7c7hdeb4zxansCgzrFHi1";
    sha256 = "f4c5b333827cb588df1842d7a8f46947f486c95b305edbbce7565925e88e86c3";
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
