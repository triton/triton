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
    version = 6;
    owner = "jedisct1";
    repo = "minisign";
    rev = version;
    sha256 = "5bfa46c0e44805d5a2d887104d9fa88f26df2ed5e19d7ee727e7c5eafb718209";
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
