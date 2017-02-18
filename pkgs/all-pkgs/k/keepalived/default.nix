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

let
  version = "1.3.3";
  year = "2017";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmRWjdPu2AAb3tvnqpzn6j5yieHN3GUXFx24Fv8GyRhbEZ";
    sha256 = "7edab46df4e3bcd591d325f1d307743642bf1ab29e5ab11b1b27a89b1ce41f0f";
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
    #net-snmp
    openssl
  ];

  postPatch = ''
    sed -i 's,$(DESTDIR)/usr/share,$out/share,g' Makefile.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    #"--enable-snmp"
    #"--enable-snmp-vrrp"
    #"--enable-snmp-checker"
    #"--enable-snmp-rfc"
    #"--enable-snmp-rfcv2"
    #"--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-sha1"
  ];

  NIX_CFLAGS_COMPILE = [
    "-DGIT_DATE=\"${version}\""
    "-DGIT_YEAR=\"${year}\""
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
