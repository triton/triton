{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "graphite2-1.3.8";

  src = fetchurl {
    url = "mirror://sourceforge/silgraphite/graphite2/${name}.tgz";
    multihash = "QmRbmYDFn4sZDjE7xGc4QM2Jx4a5Sw7KTjPB9RRp4mRWGG";
    sha256 = "9f3f25b3a8495ce0782e77f69075c0dd9b7c054847b9bf9ff130bec38f4c8cc2";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
    description = "An advanced font engine";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
