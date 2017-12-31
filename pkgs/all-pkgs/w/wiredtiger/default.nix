{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool

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
  rev = "d8f244717b6338063e0c20628bfa4bb65a821e0c";
  date = "2017-12-06";
in
stdenv.mkDerivation rec {
  name = "wiredtiger-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "wiredtiger";
    repo = "wiredtiger";
    inherit rev;
    sha256 = "90b9be2a1baccd57b194e51af18d58cd6edbff1173e7d1c92427967badff708d";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

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

  preConfigure = ''
    ./autogen.sh
  '';

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
