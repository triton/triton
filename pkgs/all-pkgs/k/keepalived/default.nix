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
  version = "2.0.19";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmNvkgTWeNU9fUiyaDt8Q6AuMKXjaRGFg8H8Ai7JJEJ6zn";
    hashOutput = false;
    sha256 = "0e2f8454765bc6a5fa26758bd9cec18aae42882843cdd24848aff0ae65ce4ca7";
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
        md5Confirm = "df670e0904d4e48e72ccc8409ad9c6de";
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
