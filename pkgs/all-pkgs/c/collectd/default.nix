{ stdenv
, fetchurl

, curl
, cyrus-sasl
, gdk-pixbuf
, jdk
, iptables
, libatasmart
#, libcredis
#, libdbi
, libgcrypt
#, libmemcached
#, libmodbus
, libnotify
#, liboping
, libpcap
#, libsigrok
#, libvirt
, libxml2
, lm-sensors
, lvm2
, mysql_lib
, net-snmp
, postgresql
, protobuf-c
, python2
#, rabbitmq-c
#, riemann
#, rrdtool
, systemd_lib
#, varnish
, yajl
}:

stdenv.mkDerivation rec {
  name = "collectd-5.6.1";

  src = fetchurl {
    url = "https://github.com/collectd/collectd/releases/download/"
      + "${name}/${name}.tar.bz2";
    sha256 = "c30ff644f91407b4dc2d99787b99cc45ec00e538bd1cc269429d3c5e8a4aee2c";
  };

  buildInputs = [
    curl
    cyrus-sasl
    gdk-pixbuf
    jdk
    iptables
    libatasmart
    libgcrypt
    libnotify
    libpcap
    libxml2
    lm-sensors
    lvm2
    mysql_lib
    net-snmp
    postgresql
    protobuf-c
    python2
    systemd_lib
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
