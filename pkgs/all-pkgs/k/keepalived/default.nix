{ stdenv
, fetchurl
, which

, glib
, ipset
, iptables
, libnfnetlink
, libnl
, net-snmp
, openssl
}:

stdenv.mkDerivation rec {
  name = "keepalived-1.3.2";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmTuQqRbQW76P9DL4dtRA3dtQ6T65vYVDCnzYScBMvdHSn";
    sha256 = "bb6729a7b7402ef5ef89e895b2dd597880702a4e2351d4da2f88bf24284e38f4";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    glib
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
    "--enable-snmp-vrrp"
    "--enable-snmp-checker"
    "--enable-snmp-rfc"
    "--enable-snmp-rfcv2"
    "--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-sha1"
  ];

  preInstall = ''
    installFlagsArray+=(
      "dbussystemdir=$out/etc/dbus-1"
      "sysconfdir=$out/etc"
    )
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
