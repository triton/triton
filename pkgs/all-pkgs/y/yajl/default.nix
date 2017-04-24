{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "yajl-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "lloyd";
    repo = "yajl";
    rev = version;
    sha256 = "a82892c2ce5c6984ed43086aced1ece9c649920ce8cd79c7a7c253e0f79f8db2";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
