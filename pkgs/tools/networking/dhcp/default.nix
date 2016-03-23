{ stdenv
, fetchurl
, makeWrapper
, perl

, coreutils
, gnused
, iproute
, iputils
, net-tools
, openldap
}:

stdenv.mkDerivation rec {
  name = "dhcp-${version}";
  version = "4.3.3-P1";

  src = fetchurl {
    url = "http://ftp.isc.org/isc/dhcp/${version}/${name}.tar.gz";
    sha256 = "08crcsmg4dm2v533aq3883ik8mf4vvvd6r998r4vrgx1zxnqj7n1";
  };

  nativeBuildInputs = [
    perl
    makeWrapper
  ];

  buildInputs = [
    openldap
  ];

  postPatch = ''
    sed -i "includes/dhcpd.h" \
      -e "s|^ *#define \+_PATH_DHCLIENT_SCRIPT.*$|#define _PATH_DHCLIENT_SCRIPT \"$out/bin/dhclient-script\"|g"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-debug"
    "--enable-failover"
    "--enable-execute"
    "--enable-tracing"
    "--enable-delayed-ack"  # Experimental in 4.3.2
    "--enable-dhcpv6"
    "--enable-paranoia"
    "--enable-early-chroot"
    "--enable-ipv4-pktinfo"
    "--disable-use-sockets"
    "--disable-secs-byteorder"
    "--disable-log-pid"
    "--without-libbind"
    "--with-ldap"
    "--with-ldapcrypto"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  postInstall = ''
    cp client/scripts/linux $out/bin/dhclient-script
    substituteInPlace $out/bin/dhclient-script \
      --replace /sbin/ip ${iproute}/bin/ip
    wrapProgram "$out/bin/dhclient-script" --prefix PATH : \
      "${net-tools}/bin:${iputils}/bin:${coreutils}/bin:${gnused}/bin"
  '';

  # Fails to build the bind library if run in parallel
  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Dynamic Host Configuration Protocol (DHCP) tools";
    homepage = http://www.isc.org/products/DHCP/;
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
