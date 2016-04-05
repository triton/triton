{ stdenv
, fetchurl

, gnutls
, jansson
, libidn
, liburcu
, lmdb
, nettle
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-2.1.1";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "e110d11d4a4c4b5abb091b32fcb073934fb840046e975234323e0fc15f2f8f5b";
  };

  buildInputs = [
    gnutls
    jansson
    libidn
    liburcu
    lmdb
    nettle
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    # "--enable-lto"
    "--enable-systemd"
    "--with-urcu=${liburcu}"
    "--with-lmdb=${lmdb}"
    "--with-libidn=${libidn}"
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
    sourceTarball = fetchurl {
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpKeyId = "EE37A832";
      pgpKeyFingerprint = "DEF3 5D16 E5AE 59D8 20BD  F780 ACE2 4DA9 EE37 A832";
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
