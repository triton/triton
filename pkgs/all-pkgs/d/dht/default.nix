{ stdenv
, cmake
, fetchFromGitHub
, ninja
, lib
}:

stdenv.mkDerivation rec {
  name = "dht-2017-09-30";

  src = fetchFromGitHub {
    version = 3;
    owner = "jech";
    repo = "dht";
    rev = "902fa6a57a5a5ae0adde7e94f4b9eb5f0b457901";
    sha256 = "9ac0ac2a668c87a03d88cea06cf7024f3b5b87265607a6e142953aa0162e0b54";
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
