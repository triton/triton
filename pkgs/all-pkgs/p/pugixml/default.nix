{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.9";
in
stdenv.mkDerivation rec {
  name = "pugixml-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "zeux";
    repo = "pugixml";
    rev = "v${version}";
    sha256 = "c55511ddf8d1233560696aea5b4af594b5c93f58ad82f8bf04e7de875d2f526b";
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
