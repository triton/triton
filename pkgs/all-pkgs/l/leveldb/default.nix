{ stdenv
, fetchFromGitHub

, kyotocabinet
, sqlite
}:

let
  version = "1.20";
in
stdenv.mkDerivation rec {
  name = "leveldb-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "google";
    repo = "leveldb";
    rev = "v${version}";
    sha256 = "5ff3768ea5515865fcc1336fdee6028ade616b9c65b17db6dea4c1a98eeeb0bf";
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
