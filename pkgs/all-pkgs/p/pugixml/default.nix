{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.8.1";
in
stdenv.mkDerivation rec {
  name = "pugixml-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "zeux";
    repo = "pugixml";
    rev = "v${version}";
    sha256 = "e9439efae818f525960d3bc8694e65c10dfb6c81ed81a9e2de5909f5c0bd16b3";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "Light-weight, simple and fast XML parser for C++ with XPath support";
    homepage = http://pugixml.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
