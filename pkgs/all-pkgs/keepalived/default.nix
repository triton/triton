{ stdenv
, fetchurl

, ipset
, iptables
, libnfnetlink
, libnl
, net-snmp
, openssl
}:

stdenv.mkDerivation rec {
  name = "keepalived-1.2.23";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmRwvzN1VhvXf56BBr9GTxeepDRnLJ9fMk4Yg18cTN9rk3";
    sha256 = "046rfl2fpzqkdy3ahg2ca8qpvdd02d0zib47m80yiwqgy6y35r0r";
  };

  buildInputs = [
    ipset
    iptables
    libnfnetlink
    libnl
    net-snmp
    openssl
  ];

  postPatch = ''
    sed -i 's,$(DESTDIR)/usr/share,$out/share,g' Makefile.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-snmp"
    "--enable-snmp-keepalived"
    "--enable-snmp-checker"
    "--enable-snmp-rfc"
    "--enable-snmp-rfcv2"
    "--enable-snmp-rfcv3"
    "--enable-sha1"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  meta = with stdenv.lib; {
    homepage = http://keepalived.org;
    description = "routing software written in C";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
