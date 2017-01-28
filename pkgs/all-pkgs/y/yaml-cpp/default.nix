{ stdenv
, cmake
, fetchFromGitHub
, ninja

, boost
}:

stdenv.mkDerivation rec {
  name = "yaml-cpp-2017-01-04";

  src = fetchFromGitHub {
    version = 2;
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "86c69bb73c497bd127afd9802d0aef8ba160f9c6";
    sha256 = "272db4a788f845fc0b886e4b8dae2fedd0cc035cd15710b41eefbd551cd15400";
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
