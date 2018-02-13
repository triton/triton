{ stdenv
, fetchurl

, fstrm
, gnutls
, jansson
, libcap-ng
, libedit
, libidn2
, liburcu
, lmdb
, nettle
, protobuf-c
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-2.6.5";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmcSCkcxK2BazgFJra1WFwe86FREp5aEZgfLdxazwSwYt1";
    hashOutput = false;
    sha256 = "33cd676706e2baeb37cf3879ccbc91a1e1cd1ee5d7a082adff4d1e753ce49d46";
  };

  buildInputs = [
    fstrm
    gnutls
    jansson
    libcap-ng
    libedit
    libidn2
    liburcu
    lmdb
    nettle
    protobuf-c
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-recvmmsg=yes"
    "--enable-reuseport=yes"
    "--enable-systemd=yes"
    "--enable-dnstap"
    "--with-urcu=${liburcu}"
    "--with-lmdb=${lmdb}"
    "--with-module-dnstap=yes"
    "--with-module-rosedb=yes"
  ];

  preInstall = ''
    sed -i '\,\$(DESTDIR)//.*knot,d' src/Makefile
    cat src/Makefile
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "config_dir=$out/etc/knot"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpKeyFingerprint = "742F A4E9 5829 B6C5 EAC6  B857 10BB 7AF6 FEBB D6AB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
