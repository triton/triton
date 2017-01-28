{ stdenv
, fetchFromGitHub

, kyotocabinet
, sqlite
}:

let
  version = "1.19";
in
stdenv.mkDerivation rec {
  name = "leveldb-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "google";
    repo = "leveldb";
    rev = "v${version}";
    sha256 = "194febd1470f39009c0540ea145f7b42cb1527ce6e630d9f23fcb6b299574b21";
  };

  buildFlags = [
    "all"
  ];

  installPhase = ''
    mkdir -p "$out"/{bin,lib,include}
    cp -r include $out
    cp out-static/leveldbutil "$out"/bin
    cp out-static/libleveldb*.a* "$out"/lib
    cp out-shared/libleveldb*.so* "$out"/lib
  '';

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
