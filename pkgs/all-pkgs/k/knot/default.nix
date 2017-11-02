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
  name = "knot-2.6.1";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmXH9awu6P53K8Zh25AaPekZj2WrwYYUmrcTJXSAuDtQ8n";
    hashOutput = false;
    sha256 = "3013d45b4c7484268f3cad078f66f730a5bc9606e6b1061488dd821c1dce41e3";
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
