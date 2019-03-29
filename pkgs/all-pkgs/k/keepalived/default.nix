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
  version = "2.0.14";
in
stdenv.mkDerivation rec {
  name = "keepalived-${version}";

  src = fetchurl {
    url = "http://keepalived.org/software/${name}.tar.gz";
    multihash = "QmaeDgKQjcX8gCVgG6pVmW4j5MKs2ttQnXSBWRgaN6htbY";
    hashOutput = false;
    sha256 = "1bf586e56ee38b47b82f2a27b27e04d0e5b23f1810db6a8e801bde9d3eb8617b";
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
        md5Confirm = "795704ce733e8dfdcfacd94183110324";
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
