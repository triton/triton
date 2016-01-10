{ stdenv, fetchurl, udev }:

stdenv.mkDerivation rec {
  name = "dhcpcd-6.10.0";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    sha256 = "0ddd2gs9imnmj37llmhqhgvrsx47bs1hzjv5m5akr4c65sdsymmb";
  };

  buildInputs = [ udev ];

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
  postInstall = stdenv.lib.optional (udev != null) ''
    [ -e $out/lib/dhcpcd/dev/udev.so ]
  '';

  meta = {
    description = "A client for the Dynamic Host Configuration Protocol (DHCP)";
    homepage = http://roy.marples.name/projects/dhcpcd;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}
