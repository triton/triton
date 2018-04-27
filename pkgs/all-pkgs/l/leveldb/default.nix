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
    version = 6;
    owner = "google";
    repo = "leveldb";
    rev = "v${version}";
    sha256 = "907eb9c7eaa604fb331be97f5e1a3f912de3f22dc116e37aa1096772b85a8955";
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
