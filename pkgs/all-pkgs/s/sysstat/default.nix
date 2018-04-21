{ stdenv
, fetchurl
, gettext

, lm-sensors
}:

stdenv.mkDerivation rec {
  name = "sysstat-11.7.3";

  src = fetchurl {
    url = "http://pagesperso-orange.fr/sebastien.godard/${name}.tar.xz";
    sha1Confirm = "d60fe0d4789cb377105c9a30f73e8e2158d3d288";
    multihash = "QmfLyAG597r7BGxbJgKjAtTxfn2RtpnVT71foZGRZrRa2x";
    sha256 = "8ea4ffcce8dae68a1cbb6acaa131ae7e3e6c5765134e670aa9baa38c1bcc66ea";
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
