{ stdenv
, fetchurl

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
  version = "2.0.7";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmdV1FHJswwYJpgmvpiRxJa5JBHzqgsAeekSgkx8xmATA6";
    hashOutput = false;
    sha256 = "bce45d6d5cf3620bfd88472ec839a75b5a14a54fda12d09e890670244873b8ab";
  };

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

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-silent-rules"
    "--enable-bfd"
    #"--enable-snmp"
    #"--enable-snmp-vrrp"
    #"--enable-snmp-checker"
    #"--enable-snmp-rfc"
    #"--enable-snmp-rfcv2"
    #"--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-json"
    "--enable-sha1"
  ];

  preInstall = ''
    installFlagsArray+=(
      "dbussystemdir=$out/etc/dbus-1"
      "sysconfdir=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Confirm = "5204f541c75f4f68339809f0761693c5";
      };
    };
  };

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
