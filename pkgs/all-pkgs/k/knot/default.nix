{ stdenv
, fetchurl

, fstrm
, gnutls
, jansson
, libedit
, libidn
, liburcu
, lmdb
, nettle
, protobuf-c
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-2.3.0";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "8abf9a6562ecf2f7f4222d16ca6c75463399870db360eda7caa40530b469533c";
  };

  buildInputs = [
    fstrm
    gnutls
    jansson
    libedit
    libidn
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
    "--with-libidn=${libidn}"
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
