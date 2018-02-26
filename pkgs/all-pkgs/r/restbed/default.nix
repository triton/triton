{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, boost_1-66
, kashmir
, openssl
}:

let
  version = "4.6";
in
stdenv.mkDerivation rec {
  name = "restbed-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "Corvusoft";
    repo = "restbed";
    rev = version;
    sha256 = "1cddb7a29ee128aa1bef032e042e37b36c9ca5b7fb3f596c96132dbf4dca4779";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost_1-66
    kashmir
    openssl
  ];
  
  postPatch = ''
    sed \
      -e '/kashmir/d' \
      -e '/asio/d' \
      -i CMakeLists.txt

    sed -e '1i#include <boost/asio/error.hpp>' \
      -i source/corvusoft/restbed/web_socket.hpp \
      -i source/corvusoft/restbed/detail/http_impl.hpp
    sed -i '/using .*system_error;/d' source/corvusoft/restbed/detail/service_impl.cpp
    find . \( -name \*.hpp -or -name \*.cpp \) -exec sed -i -e 's,std::error_code,boost::system::error_code,g' -e 's,asio::,boost::asio::,g' {} \;
  '';

  NIX_CFLAGS_COMPILE = "-I${boost_1-66.dev}/include/boost";

  NIX_LDFLAGS = "-rpath ${boost_1-66.lib}/lib -lboost_system";
  
  cmakeFlags = [
    "-DBUILD_SHARED=ON"
  ];

  postInstall = ''
    mv "$out"/library "$out"/lib
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
