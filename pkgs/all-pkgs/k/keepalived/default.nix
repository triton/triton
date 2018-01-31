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
  version = "1.4.1";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmVNEEaT7KVE7U8tbSwe4VDRBGnc95pchgPonbvRMW99Hs";
    sha256 = "220407517ccad822d1ffa80f7bc37582abaf97da6f7bda2326fa6904b1855bd0";
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
    #net-snmp
    openssl
  ];

  postPatch = ''
    sed -i 's,$(DESTDIR)/usr/share,$out/share,g' Makefile.in

    sed \
      -e 's,GENL_LIB=.*,GENL_LIB=nl-genl-3,' \
      -e 's,NL3_LIB=.*,NL3_LIB=nl-3,' \
      -e 's,ROUTE_LIB=.*,ROUTE_LIB=nl-route-3,' \
      -i configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-silent-rules"
    #"--enable-snmp"
    #"--enable-snmp-vrrp"
    #"--enable-snmp-checker"
    #"--enable-snmp-rfc"
    #"--enable-snmp-rfcv2"
    #"--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-sha1"
    "--enable-json"
  ];

  # This is a crappy hack to work around how broken the configure script is
  # at parsing pkgconfig files. This does seem to have no negative side effect.
  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -lnl-genl-3 -lnl-route-3 -lssl"
  '';

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
