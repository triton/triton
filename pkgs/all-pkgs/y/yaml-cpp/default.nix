{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  version = "0.6.2";
in
stdenv.mkDerivation rec {
  name = "yaml-cpp-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "yaml-cpp-${version}";
    sha256 = "aaad876425ad99e1dd1aecf55a7b22a5c8bb5efab9739e89f39f98627f7d927a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DYAML_CPP_BUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    description = "A YAML parser and emitter for C++";
    homepage = https://github.com/jbeder/yaml-cpp/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
