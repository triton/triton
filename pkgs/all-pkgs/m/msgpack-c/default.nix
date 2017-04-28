{ stdenv
, cmake
, fetchurl
, ninja

, zlib
}:

let
  version = "2.1.1";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "fce702408f0d228a1b9dcab69590d6a94d3938f694b95c9e5e6249617e98d83f";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    description = "MessagePack implementation for C and C++";
    homepage = http://msgpack.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
