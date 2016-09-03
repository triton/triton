{ stdenv
, cmake
, fetchFromGitHub
, ninja

, libsodium
}:

let
  version = "0.7";
in
stdenv.mkDerivation rec {
  name = "minisign-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "jedisct1";
    repo = "minisign";
    rev = version;
    sha256 = "ca07c13806d039057c711e67dc85ea01f52f2801b0db4a152aca43aeec5f674e";
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
