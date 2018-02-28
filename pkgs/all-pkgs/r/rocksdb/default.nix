{ stdenv
, fetchFromGitHub
, perl
, which

, bzip2
, gflags
, jemalloc
, lz4
, numactl
, snappy
, zlib
, zstd
}:

let
  version = "5.10.3";
in
stdenv.mkDerivation rec {
  name = "rocksdb-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "facebook";
    repo = "rocksdb";
    rev = "v${version}";
    sha256 = "8a5e3a076707623b3a17502256f94f1ebd40853fd1af187966ce3ae34a6bd77b";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    bzip2
    gflags
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
  DISABLE_WARNING_AS_ERROR = "1";
  PORTABLE = "1";
  USE_SSE = "1";
  CMAKE_CXX_FLAGS = "-std=gnu++11";
  JEMALLOC_LIB = "-ljemalloc";

  makeFlags = [
    "USE_RTTI=1" # Needed for ceph
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
