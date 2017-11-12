{ stdenv
, fetchurl
, which

, glib
, ipset
, iptables
, json-c
, libnfnetlink
, libnl
, net-snmp
, openssl
}:

let
  version = "1.3.9";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmQkPJLuWbH9EtVAqJowM9atAaCKGn1xUgBJu2RSVZSqoJ";
    sha256 = "d5bdd25530acf60989222fd92fbfd596e06ecc356a820f4c1015708b76a8d4f3";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    glib
    ipset
    iptables
    json-c
    libnfnetlink
    libnl
    net-snmp
    openssl
  ];

  postPatch = ''
    sed -i 's,$(DESTDIR)/usr/share,$out/share,g' Makefile.in

    sed \
      -e 's,GENL_LIB=.*,GENL_LIB=nl-genl-3,' \
      -e 's,NL3_LIB=.*,NL3_LIB=nl-3,' \
      -e 's,ROUTE_LIB=.*,ROUTE_LIB=nl-route-3,' \
      -i configure

    cat configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-silent-rules"
    "--enable-snmp"
    "--enable-snmp-vrrp"
    "--enable-snmp-checker"
    "--enable-snmp-rfc"
    "--enable-snmp-rfcv2"
    "--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-sha1"
    "--enable-json"
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
