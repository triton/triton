{ stdenv
, cmake
, fetchFromGitHub
, ninja

, boost
}:

stdenv.mkDerivation rec {
  name = "yaml-cpp-2017-04-03";

  src = fetchFromGitHub {
    version = 2;
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "11607eb5bf1258641d80f7051e7cf09e317b4746";
    sha256 = "d435525d5b2761d4b2212177e3ba78d88db956611c26b9c41af4af66f05cbf80";
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
