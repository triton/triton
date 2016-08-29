{ stdenv
, autoreconfHook
, cmake
, fetchzip
, ninja

, python2
}:

# This is a really fucked up build that uses both autoconf and cmake.
# Autoconf is only used to generate scripts/gtest-config & fused-gtest,
# but requires running autoreconf and automake's makefile.

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "googletest-${version}";

  src = fetchzip {
    url = "https://github.com/google/googletest/archive/"
      + "release-${version}.tar.gz";
    sha256 = "6c0f5c6f4e325b840ac9c69b0e70e0c21eacfce31c1bdcaad685879dff21d5bc";
  };

  nativeBuildInputs = [
    autoreconfHook
    cmake
    ninja
  ];

  buildInputs = [
    python2
  ];

  patches = [
    (fetchTritonPatch {
      rev = "6a37c554e6436f5fb5d891cb690dbc2d255ad354";
      file = "g/googletest/googletest-1.8.0-pkgconfig.patch";
      sha256 = "61eb45539a66bb365de6712aec712b0e73795eb0ba70e6b44894031909a92237";
    })
  ];

  postUnpack = /* Make sure sourceRoot is an absolute path */ ''
    pushd "$sourceRoot"
      sourceRoot="$(pwd)"
    popd

    cp -v ${./gtest.pc.in} $sourceRoot/googletest/gtest.pc.in
    sed -i $sourceRoot/googletest/gtest.pc.in \
      -e 's|(Version:) .+|1 ${version}|'
  '';

  postPatch = ''
    patchShebangs ./googletest/scripts/fuse_gtest_files.py
  '';

  preAutoreconf = ''
    cd "$sourceRoot/googletest"
  '';

  postAutoreconf = ''
    cd "$sourceRoot"
  '';

  preConfigure = ''
    cd "$sourceRoot/googletest"
      ./configure --with-pthreads
      make -f ./Makefile -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES fused-gtest
    cd "$sourceRoot"
  '';

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_GTEST=ON"
    "-DBUILD_GMOCK=ON"
    "-Dgmock_build_tests=OFF"
    "-Dgtest_build_tests=OFF"
    "-Dgtest_build_samples=OFF"
    "-Dgtest_disable_pthreads=OFF"
    "-Dgtest_hide_internal_symbols=OFF"
  ];

  postInstall = ''
    pushd $sourceRoot/googletest
      install -D -m755 -v scripts/gtest-config -t "$out"/bin
      install -D -m644 -v m4/gtest.m4 -t "$out"/share/aclocal
      install -D -m644 -v fused-src/gtest/* -t "$out"/src/gtest/src
      install -D -m644 -v cmake/* -t "$out"/src/gtest/cmake
      install -D -m644 -v CMakeLists.txt -t "$out"/src/gtest
    popd
  '';

  meta = with stdenv.lib; {
    description = "Google C++ Testing Framework";
    homepage = https://github.com/google/googletest;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
