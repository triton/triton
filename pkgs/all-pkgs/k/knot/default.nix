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
  name = "knot-2.8.1";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmfXmQfMX7x1ZPqFWeXE2yXhkDbnTr2JMLvtWnyRY91kFp";
    hashOutput = false;
    sha256 = "b21bf03e5cb6804df4e0e8b3898446349e86ddae5bf110edaf240d0ad1e2a2c6";
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
