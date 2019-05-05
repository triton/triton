{ stdenv
, fetchurl
, file

, libpcap
, ncurses
, openssl
, pcre
, pciutils
}:

let
  version = "5.8";
in
stdenv.mkDerivation rec {
  name = "net-snmp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/net-snmp/net-snmp/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b2fc3500840ebe532734c4786b0da4ef0a5f67e51ef4c86b3345d697e4976adf";
  };

  nativeBuildInputs = [
    file
  ];

  buildInputs = [
    libpcap
    ncurses
    openssl
    pcre
    pciutils
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    # TODO: Broken in 5.8
    #"--disable-des"
    #"--disable-md5"
    "--enable-daemons-syslog-as-default"
    "--disable-debugging"
    "--disable-deprecated"
    "--disable-embedded-perl"
    "--with-systemd"
    "--with-logfile=/var/log/snmpd.log"
    "--with-persistent-directory=/var/lib/snmp"
    "--with-mnttab=/proc/mounts"
  ];

  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "D0F8 F495 DA61 60C4 4EFF  BF10 F07B 9D2D ACB1 9FD6";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Clients and server for the SNMP network monitoring protocol";
    homepage = http://net-snmp.sourceforge.net/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
