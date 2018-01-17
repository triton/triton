{ stdenv
, fetchTritonPatch
, fetchurl
, file
, perlPackages

, libnl
, lm-sensors
, openssl
, pciutils
}:

let
  version = "5.7.3";
in
stdenv.mkDerivation rec {
  name = "net-snmp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/net-snmp/net-snmp/${version}/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmW7RctNcJdAKcqoayYwRUDWmzbZHAT4R3tLvpFuFBWxLE";
    sha256 = "12ef89613c7707dc96d13335f153c1921efc9d61d3708ef09f3fc4a7014fb4f0";
  };

  nativeBuildInputs = [
    file
    perlPackages.perl
  ];

  buildInputs = [
    libnl
    lm-sensors
    openssl
    pciutils
  ];

  patches = [
    (fetchTritonPatch {
      rev = "e4e2b13f53b7419e829273fa3408ad71d10f5fdb";
      file = "n/net-snmp/openssl-1.1.0.patch";
      sha256 = "5ca97127a6201372b0d758d844e0cb06decbd146998b8d49f9a430a83e1aadb5";
    })
    (fetchTritonPatch {
      rev = "e4e2b13f53b7419e829273fa3408ad71d10f5fdb";
      file = "n/net-snmp/perl-5.24-fix.patch";
      sha256 = "56962215c560e4b7870300118855c132b96a542f8568ce16d95d195816e47cfd";
    })
  ];

  preConfigure = ''
    # http://comments.gmane.org/gmane.network.net-snmp.user/32434
    sed -i 'man/Makefile.in' \
      -e 's/grep -vE/@EGREP@ -v/'
  '';

  configureFlags = [
    "--enable-ucd-snmp-compatibility"
    "--disable-des"
    "--disable-md5"
    "--disable-embedded-perl"
    "--with-default-snmp-version=3"
    "--with-sys-location=Unknown"
    "--with-sys-contact=root@unknown"
    "--with-logfile=/var/log/snmpd.log"
    "--with-persistent-directory=/var/lib/snmp"
    "--with-mnttab=/proc/mounts"
  ];

  preInstall = ''
    perlversion=$(perl -e 'use Config; print $Config{version};')
    perlarchname=$(perl -e 'use Config; print $Config{archname};')
    installFlagsArray+=(
      "INSTALLSITEARCH=$out/${perlPackages.perl.libPrefix}/$perlversion/$perlarchname"
      "INSTALLSITEMAN3DIR=$out/share/man/man3"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "27CA A4A3 2E37 1383 A33E  D058 7D5F 9576 E0F8 1533";
      inherit (src) urls outputHash outputHashAlgo;
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
