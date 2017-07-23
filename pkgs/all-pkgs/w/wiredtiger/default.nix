{ stdenv
, fetchurl

, bzip2
, db
, gperftools
, leveldb
, lz4
, snappy
, zlib
, zstd
}:

let
  version = "2.9.3";
in
stdenv.mkDerivation rec {
  name = "wiredtiger-${version}";

  src = fetchurl {
    url = "https://github.com/wiredtiger/wiredtiger/releases/download/${version}/${name}.tar.bz2";
    sha256 = "2502a90d6b3d3cae0b1bf221cbfe13999d3bcb7f8bb9fa795ad870be4fc0e1e7";
  };

  buildInputs = [
    bzip2
    db
    gperftools
    leveldb
    lz4
    snappy
    zlib
    zstd
  ];

  configureFlags = [
    "--enable-leveldb"
    "--enable-tcmalloc"
    "--with-builtins=lz4,snappy,zlib,zstd"
    "--with-berkeleydb=${db}"
    "--without-helium"
  ];

  meta = with stdenv.lib; {
    homepage = http://wiredtiger.com/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
