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
  name = "knot-resolver-2.2.0";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-resolver/${name}.tar.xz";
    multihash = "QmdLFKihbtwQYGUemyWfnM7BikxEwgk5BrXoH63ZyAHJgo";
    hashOutput = false;
    sha256 = "7bb7f0cd8bbb1d99706d56ed119bdffce094628479438896f3740644efe614fa";
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
