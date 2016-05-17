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
  name = "keepalived-1.2.20";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    sha256 = "1gw15z9996cfz9ppdvrnyf8sc0grgnc2pf9smgaca08g34bvjssn";
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
    "--enable-sha1"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
  ];

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
