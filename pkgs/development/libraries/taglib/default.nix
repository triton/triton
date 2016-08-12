{stdenv, fetchurl, zlib, cmake, ninja}:

stdenv.mkDerivation rec {
  name = "taglib-1.11";

  src = fetchurl {
    url = "https://taglib.github.io/releases/${name}.tar.gz";
    sha256 = "ed4cabb3d970ff9a30b2620071c2b054c4347f44fc63546dbe06f97980ece288";
  };

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DWITH_ASF=ON"
    "-DWITH_MP4=ON"
  ];

  buildInputs = [ zlib ];
  nativeBuildInputs = [ cmake ninja ];

  meta = {
    homepage = http://developer.kde.org/~wheeler/taglib.html;
    repositories.git = git://github.com/taglib/taglib.git;

    description = "A library for reading and editing the meta-data of several popular audio formats";
    inherit (cmake.meta) platforms;
    maintainers = [ stdenv.lib.maintainers.urkud ];
  };
}
