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
, pcre2_lib
}:

let
  version = "2.0.11";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "Qmdhm3KTyBnwPd3SKEYi56sQcZUYgzvzs7e9kH958Lw9yV";
    hashOutput = false;
    sha256 = "a298b0c02a20959cfc365b62c14f45abd50d5e0595b2869f5bce10ec2392fa48";
  };

  buildInputs = [
    glib
    ipset
    iptables
    json-c
    libnfnetlink
    libnl
    net-snmp
    openssl
    pcre2_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-silent-rules"
    "--enable-bfd"
    "--enable-snmp"
    "--enable-snmp-vrrp"
    "--enable-snmp-checker"
    "--enable-snmp-rfc"
    "--enable-snmp-rfcv2"
    "--enable-snmp-rfcv3"
    "--enable-dbus"
    "--enable-regex"
    "--enable-regex-timers"
    "--enable-json"
    "--enable-sha1"
    "--enable-dynamic-linking"
    "--enable-netlink-timers"
    "--with-init=systemd"
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-systemdsystemunitdir=$out/lib/systemd/system")
  '';

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
        md5Confirm = "2a6e1a159922afd78333cd683f9f2732";
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
