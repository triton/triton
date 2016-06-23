{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation rec {
  name = "pugixml-${version}";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "zeux";
    repo = "pugixml";
    rev = "v${version}";
    sha256 = "3c2ec1a33b846f9adf9451320f84a1dd6d50347534f64ab1d78ed7f5b638840e";
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

  meta = with stdenv.lib; {
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
