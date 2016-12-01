{ stdenv
, fetchurl

, curl
, cyrus-sasl
, gdk-pixbuf
, gpsd
, grpc
, hiredis
, i2c-tools
, iptables
, jdk
, libatasmart
, libcap
, libdbi
, libgcrypt
, libmnl
, libnotify
, liboping
, libpcap
, libxml2
, lm-sensors
, lua
, lvm2
, mysql_lib
, net-snmp
, openldap
, perl
, postgresql
, protobuf-c
, protobuf-cpp
, python2
, python3
, rrdtool
, systemd_lib
, xfsprogs_lib
, yajl
}:

stdenv.mkDerivation rec {
  name = "collectd-5.6.2";

  src = fetchurl {
    urls = [
      "https://storage.googleapis.com/collectd-tarballs/${name}.tar.bz2"
      "https://github.com/collectd/collectd/releases/download/${name}/${name}.tar.bz2"
    ];
    hashOutput = false;  # Hashes at: https://collectd.org/download.shtml
    sha256 = "cc0b4118a91e5369409ced22d1d8a85c1a400098419414160c1839268ecad0c6";
  };

  buildInputs = [
    curl
    cyrus-sasl
    gdk-pixbuf
    gpsd
    grpc
    hiredis
    i2c-tools
    iptables
    jdk
    libatasmart
    libcap
    libdbi
    libgcrypt
    libmnl
    libnotify
    liboping
    libpcap
    libxml2
    lm-sensors
    lua
    lvm2
    mysql_lib
    net-snmp
    openldap
    perl
    postgresql
    protobuf-c
    protobuf-cpp
    python2
    python3
    rrdtool
    systemd_lib
    xfsprogs_lib
    yajl
  ];

  meta = with stdenv.lib; {
    description = "System statistics collection daemon";
    homepage = http://collectd.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
