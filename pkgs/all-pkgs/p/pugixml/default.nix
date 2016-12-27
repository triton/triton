{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.8";
in
stdenv.mkDerivation rec {
  name = "pugixml-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "zeux";
    repo = "pugixml";
    rev = "v${version}";
    sha256 = "4c66adfdccb5bd62715c8108a2f3ea610f988b53104f02bf4a1317d2728ea082";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  preConfigure = ''
    # Enable long long support (required for filezilla)
    #sed -ire '/PUGIXML_HAS_LONG_LONG/ s/^\/\///' src/pugiconfig.hpp
    cd scripts
  '';

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
