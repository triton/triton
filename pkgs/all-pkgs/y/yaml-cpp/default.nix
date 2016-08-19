{ stdenv
, cmake
, fetchFromGitHub
, ninja

, boost
}:

stdenv.mkDerivation rec {
  name = "yaml-cpp-0.5.3";

  src = fetchFromGitHub {
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = name;
    sha256 = "dfe4b9fc9ee8fb7d1e3e6d80380e53f7786acdf781b56ad6a1c7370ccd2cc8eb";
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
