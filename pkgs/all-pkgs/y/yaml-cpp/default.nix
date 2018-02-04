{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  version = "0.6.1";
in
stdenv.mkDerivation rec {
  name = "yaml-cpp-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "yaml-cpp-${version}";
    sha256 = "264e3e3916509d5d2f32125dd0f884d2e35f15bdfbf914fe13ec8952f62d3713";
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
