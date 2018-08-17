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
  name = "knot-2.7.1";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmYK9fxz1rJEmQCHz5QCHjGMoVEYUG5j3kkmhLcQsWqbrM";
    hashOutput = false;
    sha256 = "7d6ae20ada0f0ee7700d5df17f47f86b49eb21ee34977d0d70de6a0947371381";
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
