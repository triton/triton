{ stdenv
, cmake
, fetchurl
, ninja

, libsodium
}:

stdenv.mkDerivation rec {
  name = "minisign-${version}";
  version = "0.6";

  src = fetchurl {
    url = "https://github.com/jedisct1/minisign/archive/${version}.tar.gz";
    sha256 = "f2267a07bece923d4d174ccacccc56eff9c05b28c4d971e601de896355442f09";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libsodium
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
