{ stdenv
, fetchTritonPatch
, fetchurl
, file
, perlPackages

, openssl
}:

stdenv.mkDerivation rec {
  name = "net-snmp-5.7.3";

  src = fetchurl {
    url = "mirror://sourceforge/net-snmp/${name}.tar.gz";
    allowHashOutput = false;
    multihash = "QmW7RctNcJdAKcqoayYwRUDWmzbZHAT4R3tLvpFuFBWxLE";
    sha256 = "12ef89613c7707dc96d13335f153c1921efc9d61d3708ef09f3fc4a7014fb4f0";
  };

  nativeBuildInputs = [
    file
    perlPackages.perl
  ];

  buildInputs = [
    openssl
  ];

  patches = [
    (fetchTritonPatch {
      rev = "fa150c43b9b4f3d0f3a01badc7cf368ebb1b34ab";
      file = "net-snmp/perl-5.24-fix.patch";
      sha256 = "56962215c560e4b7870300118855c132b96a542f8568ce16d95d195816e47cfd";
    })
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
