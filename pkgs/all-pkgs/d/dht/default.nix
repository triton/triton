{ stdenv
, cmake
, ninja
, fetchzip
, lib
}:

stdenv.mkDerivation rec {
  name = "dht-0.24";

  src = fetchzip {
    version = 2;
    url = "https://github.com/jech/dht/archive/${name}.tar.gz";
    sha256 = "a63327239eb81e97c4c78460f798de794fa910c7c1e66d7ecb7e4dc85329c06e";
  };

  postPatch = ''
    ln -sv ${./CMakeLists.txt} CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with lib; {
    description = "BitTorrent DHT library";
    homepage = https://github.com/jech/dht/releases;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
