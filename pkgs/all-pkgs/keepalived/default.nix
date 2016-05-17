{ stdenv
, fetchFromGitHub

, ipset
, iptables
, libnfnetlink
, libnl
, net-snmp
, openssl
}:

stdenv.mkDerivation rec {
  name = "keepalived-2016-05-17";

  src = fetchFromGitHub {
    owner = "acassen";
    repo = "keepalived";
    rev = "d96429be4a4f5df2bc70d1d83477fad0ea827b1a";
    sha256 = "438bc7c6f11c6e20d32b7adff8dfdfdd81e7a5155c9ece2bf4b681bf3857ecb9";
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
