{ stdenv
, fetchurl
, perl

, gperftools
, libcap
, libevent
, libscrypt
, libseccomp
, libsodium
, openssl
, systemd_lib
, xz
, zlib
, zstd
}:

stdenv.mkDerivation rec {
  name = "tor-0.3.4.8";

  src = fetchurl {
    url = "https://www.torproject.org/dist/${name}.tar.gz";
    multihash = "QmdtxgrkKdQe9qhoEb7MxMv4yyJYtS4apF7s1gAxrywV7t";
    hashOutput = false;
    sha256 = "826a4cb2c099a29c7cf91516ffffcfcb5aace7533b8853a8c8bddcfe2bfb1023";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    gperftools
    libcap
    libevent
    libscrypt
    libseccomp
    libsodium
    openssl
    systemd_lib
    xz
    zlib
    zstd
  ];

  postPatch = ''
    # Remove donna curve25519
    grep -q 'x$tor_cv_can_use_curve25519_donna_c64"' configure
    sed -i 's,"x$tor_cv_can_use_curve25519_donna_c64","xno",g' configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-unittests"
    "--enable-systemd"
    "--enable-lzma"
    "--enable-zstd"
    "--with-tcmalloc"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
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
        pgpKeyFingerprints = [
          "B35B F85B F194 89D0 4E28  C33C 2119 4EBB 1657 33EA"
          "2133 BC60 0AB1 33E1 D826  D173 FE43 009C 4607 B1FB"
        ];
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
