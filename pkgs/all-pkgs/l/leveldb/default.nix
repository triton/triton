{ stdenv
, fetchFromGitHub

, kyotocabinet
, sqlite
}:

stdenv.mkDerivation rec {
  name = "leveldb-${version}";
  version = "1.18";

  src = fetchFromGitHub {
    version = 1;
    owner = "google";
    repo = "leveldb";
    rev = "v${version}";
    sha256 = "6cce5114ed37a80ed6da3e9b580879d805eabb6e1fc101c2015f13469308469a";
  };

  buildInputs = [
    kyotocabinet
    sqlite
  ];

  buildPhase = ''
    make all db_bench{,_sqlite3,_tree_db} leveldbutil libmemenv.a
  '';

  installPhase = "
    mkdir -p $out/{bin,lib,include}
    cp -r include $out
    cp lib* $out/lib
    cp db_bench{,_sqlite3,_tree_db} leveldbutil $out/bin
    mkdir -p $out/include/leveldb/helpers
    cp helpers/memenv/memenv.h $out/include/leveldb/helpers
  ";

  meta = with stdenv.lib; {
    homepage = "https://code.google.com/p/leveldb/";
    description = "Fast and lightweight key/value database library by Google";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
