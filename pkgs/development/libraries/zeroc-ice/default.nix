{ stdenv, fetchFromGitHub, mcpp, bzip2, expat, openssl, db }:

stdenv.mkDerivation rec {
  name = "zeroc-ice-${version}";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "2996782d46aa98a0fa699c3c7b75451de8d9d56dec6f8d94450e9246c690cef4";
  };

  buildInputs = [ mcpp bzip2 expat openssl db ];

  buildPhase = ''
    cd cpp
    make -j $NIX_BUILD_CORES OPTIMIZE=yes
  '';

  installPhase = ''
    make -j $NIX_BUILD_CORES prefix=$out install
  '';

  meta = with stdenv.lib; {
    homepage = "http://www.zeroc.com/ice.html";
    description = "The internet communications engine";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
