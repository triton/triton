{ stdenv
, fetchurl

, fstrm
, gnutls
, jansson
, libcap-ng
, libedit
, libidn2
, libmaxminddb
, liburcu
, lmdb
, protobuf-c
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-2.7.6";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmThtYXtvA3simDLG8N3eGAQGyr2SA8CWH3H8JDoYxX2zS";
    hashOutput = false;
    sha256 = "a1cb1877f04f7c2549c977c2658cfafd07c7e0e924f8e8aa8d4ae4b707f697a2";
  };

  buildInputs = [
    fstrm
    gnutls
    jansson
    libcap-ng
    libedit
    libidn2
    libmaxminddb
    liburcu
    lmdb
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
    grep -q '\$(DESTDIR)//' src/Makefile
    sed -i '\,\$(DESTDIR)//,d' src/Makefile

    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "config_dir=$out/etc/knot"
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
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        sha256Urls = map (n: "${n}.sha256") src.urls;
        pgpKeyFingerprint = "742F A4E9 5829 B6C5 EAC6  B857 10BB 7AF6 FEBB D6AB";
      };
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
