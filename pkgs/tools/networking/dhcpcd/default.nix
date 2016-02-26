{ stdenv, fetchurl, systemd_lib }:

stdenv.mkDerivation rec {
  name = "dhcpcd-6.10.1";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    sha256 = "0yxfx3r6ik47rsv1f8q7siw0vas6jcsrbjpaqnx0nn707f6byji8";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  # Hack to make installation succeed.  dhcpcd will still use /var/db
  # at runtime.
  preInstall = ''
    installFlagsArray+=("DBDIR=$TMPDIR/db" "SYSCONFDIR=$out/etc")
  '';

  # Check that the udev plugin got built.
  postInstall = ''
    [ -e $out/lib/dhcpcd/dev/udev.so ]
  '';

  meta = {
    description = "A client for the Dynamic Host Configuration Protocol (DHCP)";
    homepage = http://roy.marples.name/projects/dhcpcd;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}
