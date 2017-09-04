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
  name = "knot-2.5.4";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmcRVTVF98H1ZhAN3RvCKczapL36stT11uwfsqLo2qvtjj";
    hashOutput = false;
    sha256 = "3fde76e9084b75df374709cb73a8289f77c6a95b7ccff8584d7423566faa24f0";
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
    # "--enable-lto"
    "--enable-systemd"
    "--with-urcu=${liburcu}"
    "--with-lmdb=${lmdb}"
    "--enable-dnstap"
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
