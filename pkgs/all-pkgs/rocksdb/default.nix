{ stdenv
, fetchFromGitHub
, perl

, bzip2
, google-gflags
, jemalloc
, lz4
, numactl
, snappy
, zlib
, zstd
}:

stdenv.mkDerivation rec {
  name = "rocksdb-${version}";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "rocksdb";
    rev = "v${version}";
    sha256 = "1b9b1ef7d63c9b0c35ff5290fa697e6830ce977b4885bbb8e90388f9b1c8b7e5";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    bzip2
    google-gflags
    jemalloc
    lz4
    numactl
    snappy
    zlib
    zstd
  ];

  postPatch = ''
    # Hack to fix typos
    sed -i 's,#inlcude,#include,g' build_tools/build_detect_platform
  '';

  # Environment vars used for building certain configurations
  PORTABLE = "1";
  USE_SSE = "1";
  CMAKE_CXX_FLAGS = "-std=gnu++11";
  JEMALLOC_LIB = "-ljemalloc";

  makeFlags = [
    "DEBUG_LEVEL=0"
  ];

  buildFlags = [
    "shared_lib"
    "static_lib"
  ];

  installFlags = [
    "INSTALL_PATH=\${out}"
  ];

  installTargets = [
    "install-shared"
    "install-static"
  ];

  postInstall = ''
    # Might eventually remove this when we are confident in the build process
    echo "BUILD CONFIGURATION FOR SANITY CHECKING"
    cat make_config.mk
  '';

  meta = with stdenv.lib; {
    homepage = http://rocksdb.org;
    description = "A library that provides an embeddable, persistent key-value store for fast storage";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
