{ stdenv
, cmake
, fetchFromGitHub
, ninja

, boost
}:

let
  rev = "86ae3a5aa7e2109d849b2df89176d6432a35265d";
  date = "2017-11-29";
in
stdenv.mkDerivation rec {
  name = "yaml-cpp-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "jbeder";
    repo = "yaml-cpp";
    inherit rev;
    sha256 = "6b48a37f85f5033d5ebb03caa1f2e2b587fd9543c2a882f16aec69f42b2b97b6";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
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
