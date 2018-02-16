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
  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "wiredtiger-${version}";

  src = fetchurl {
    url = "https://github.com/wiredtiger/wiredtiger/releases/download/${version}/${name}.tar.bz2";
    sha256 = "a6662ecedc824ed61895c34821a1f9adbf5d3cf04630fa3d3881cb2b9573a304";
  };

  buildInputs = [
    bzip2
    db
    gperftools
    lz4
    snappy
    zlib
    zstd
  ];

  configureFlags = [
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
