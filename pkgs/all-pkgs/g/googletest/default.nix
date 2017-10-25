{ stdenv
, autoreconfHook
, cmake
, fetchTritonPatch
, fetchFromGitHub
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

  src = fetchFromGitHub {
    version = 3;
    owner = "google";
    repo = "googletest";
    rev = "release-${version}";
    sha256 = "2c62c73fa68be8a9d38bb19c741757323b07e7317eafa9a8a76c60db0c8108f0";
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

  postUnpack = /* Make sure srcRoot is an absolute path */ ''
    pushd "$srcRoot"
      srcRoot="$(pwd)"
    popd
  '';

  prePatch = ''
    cp -v ${./gtest.pc.in} $srcRoot/googletest/gtest.pc.in
    sed -i $srcRoot/googletest/gtest.pc.in \
      -e 's|(Version:) .+|1 ${version}|'
  '';

  postPatch = ''
    patchShebangs ./googletest/scripts/fuse_gtest_files.py
  '';

  preAutoreconf = ''
    cd "$srcRoot/googletest"
  '';

  postAutoreconf = ''
    cd "$srcRoot"
  '';

  preConfigure = ''
    cd "$srcRoot/googletest"
      ./configure --with-pthreads
      make -f ./Makefile -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES fused-gtest
    cd "$srcRoot"
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
    pushd $srcRoot/googletest
      install -D -m755 -v scripts/gtest-config -t "$out"/bin
      install -D -m644 -v m4/gtest.m4 -t "$out"/share/aclocal
      install -D -m644 -v fused-src/gtest/* -t "$out"/share/gtest/src/src
      install -D -m644 -v cmake/* -t "$out"/share/gtest/src/cmake
      install -D -m644 -v CMakeLists.txt -t "$out"/share/gtest/src
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
