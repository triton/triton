{ stdenv
, fetchurl
, util-linux_full
, which

, fstrm
, gnutls
, knot
, libedit
, libuv
, lmdb
, luajit
, nettle
, protobuf-c
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-resolver-2.3.0";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-resolver/${name}.tar.xz";
    multihash = "QmYXhRkffBh5PaqGwT4HrQacyip2Ua39MGd9ExHqp7Rpe1";
    hashOutput = false;
    sha256 = "2d19c5daf8440bd3d2acd1886b9ede65f04f7753c6fd4618a92a1a4ba3b27a9b";
  };

  nativeBuildInputs = [
    util-linux_full
    which
  ];

  buildInputs = [
    fstrm
    gnutls
    knot
    libedit
    libuv
    lmdb
    luajit
    nettle
    protobuf-c
    systemd_lib
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "lmdb_LIBS=-llmdb"
    )
    buildFlagsArray+=(
      "ETCDIR=/etc/knot-resolver"
    )
    installFlagsArray+=(
      "ETCDIR=$out/etc/knot-resolver"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpKeyFingerprint = "4A8B A48C 2AED 933B D495  C509 A1FB A5F7 EF8C 4869";
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
