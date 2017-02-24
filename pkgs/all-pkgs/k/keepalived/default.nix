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
  version = "1.3.4";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmUsAQHNfpBtGgxuYQa8aLQxLDB6vegepd8KfEEpadFsVw";
    sha256 = "d946e3db6f1b2ec8c8fd255c0a4d2d326d1539db61136ba147d33ef219e3a754";
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
