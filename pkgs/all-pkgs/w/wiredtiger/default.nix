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
  version = "2.9.0";
in
stdenv.mkDerivation rec {
  name = "wiredtiger-${version}";

  src = fetchurl {
    url = "https://github.com/wiredtiger/wiredtiger/releases/download/${version}/${name}.tar.bz2";
    sha256 = "bdbd14753f704a2d7ffc7d132548ca8d2d29938821df747712165699c18c587e";
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
