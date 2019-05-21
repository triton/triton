{ stdenv
, fetchurl

, file
, glib
, ipset
, iptables
, json-c
, libnfnetlink
, libnl
, linux-headers_triton
, net-snmp
, openssl
, pcre2_lib
}:

let
  version = "2.0.16";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmQzkdBLujk2WDYs1STD9Uy9CHfZZtWk3DtbpZxmL88YVw";
    hashOutput = false;
    sha256 = "f0c7dc86147a286913c1c2c918f557735016285d25779d4d2fce5732fcb888df";
  };

  buildInputs = [
    file
    glib
    ipset
    iptables
    json-c
    libnfnetlink
    libnl
    linux-headers_triton
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
        md5Confirm = "03f202eace2ad392c61ced15bb710e24";
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
