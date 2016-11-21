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
}:

stdenv.mkDerivation rec {
  name = "wiredtiger-${version}";
  version = "2.8.0";

  src = fetchFromGitHub {
    version = 1;
    repo = "wiredtiger";
    owner = "wiredtiger";
    rev = version;
    sha256 = "70ba31afabe65f02f84b1edeebf0c6be8eac93056b20a4027ae11b77eabc85a6";
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
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--enable-leveldb"
    "--enable-tcmalloc"
    "--with-builtins=lz4,snappy,zlib"
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
