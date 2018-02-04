{ stdenv
, cmake
, fetchFromGitHub
, ninja

, libsodium
}:

let
  version = "0.8";
in
stdenv.mkDerivation rec {
  name = "minisign-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "jedisct1";
    repo = "minisign";
    rev = version;
    sha256 = "467b7085df42284be24d66ccb605d69fa71b9f6cf518c2d7f6eea40eafca1536";
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
