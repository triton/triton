{ stdenv
, fetchurl
, file
, perl
, unzip

, openssl
}:

stdenv.mkDerivation rec {
  name = "net-snmp-5.7.3";

  src = fetchurl {
    url = "mirror://sourceforge/net-snmp/${name}.zip";
    multihash = "QmPjQkxMk6KDfjDnTFG322EKsbVzdAnnbnNPR4tMLCGy9n";
    sha256 = "0gkss3zclm23zwpqfhddca8278id7pk6qx1mydpimdrrcndwgpz8";
  };

  nativeBuildInputs = [
    file
    perl
    unzip
  ];

  buildInputs = [
    openssl
  ];

  preConfigure = ''
    # http://comments.gmane.org/gmane.network.net-snmp.user/32434
    substituteInPlace "man/Makefile.in" --replace 'grep -vE' '@EGREP@ -v'
  '';

  configureFlags = [
    "--with-default-snmp-version=3"
    "--with-sys-location=Unknown"
    "--with-sys-contact=root@unknown"
    "--with-logfile=/var/log/net-snmpd.log"
    "--with-persistent-directory=/var/lib/net-snmp"
    "--with-openssl=${openssl}"
    "--with-mnttab=/proc/mounts"
  ];

  preInstall = ''
    perlversion=$(perl -e 'use Config; print $Config{version};')
    perlarchname=$(perl -e 'use Config; print $Config{archname};')
    installFlagsArray+=(
      "INSTALLSITEARCH=$out/lib/perl5/site_perl/$perlversion/$perlarchname"
      "INSTALLSITEMAN3DIR=$out/share/man/man3"
    )
  '';

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
