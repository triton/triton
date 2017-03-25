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
  version = "1.3.5";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmZnN7LTTWqwERvZXEKRZkWYvJAcJenwtbRo3MN5D9ySm7";
    sha256 = "c0114d86ea4c896557beb0d9367819a423ffba772bc5d7c548dc455e6b3bd048";
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
