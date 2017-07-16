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
    version = 3;
    owner = "jedisct1";
    repo = "minisign";
    rev = version;
    sha256 = "6278de7053bcdfb2e458bbed89b9570346291eba545f0d637ac117a512071533";
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
