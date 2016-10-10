{ stdenv
, cmake
, fetchurl
, ninja

, zlib
}:

let
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "41de0989a3385061ab7307a1005655e780def6fc9c89af0ec942616aa787e136";
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
