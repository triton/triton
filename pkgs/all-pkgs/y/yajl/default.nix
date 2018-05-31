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
    version = 6;
    owner = "lloyd";
    repo = "yajl";
    rev = version;
    sha256 = "bc9987663ea2ae312f9cfb7e33a0ff053668fff151a1a61f8afe7aab23485c74";
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
