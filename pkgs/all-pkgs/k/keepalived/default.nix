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
  name = "keepalived-1.2.24";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmVUJ7SnDaW6Dj9AyKwnnKa2wbQbHRznWfGzrraFgL1CAH";
    sha256 = "3071804478077e606197a2348b5733d7d53af2843906af5e0d544945565c36ef";
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
