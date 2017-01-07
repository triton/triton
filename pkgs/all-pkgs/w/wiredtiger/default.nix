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
  version = "2.9.1";
in
stdenv.mkDerivation rec {
  name = "wiredtiger-${version}";

  src = fetchurl {
    url = "https://github.com/wiredtiger/wiredtiger/releases/download/${version}/${name}.tar.bz2";
    sha256 = "2995acab3422f1667b50e487106c6c88b8666d3cf239d8ecffa2dbffb17dfdcf";
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
