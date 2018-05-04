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
  version = "5.12.4";
in
stdenv.mkDerivation rec {
  name = "rocksdb-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "facebook";
    repo = "rocksdb";
    rev = "v${version}";
    sha256 = "6586347bf874663c72eb54e13f94705e9ddf3b9aed6b49b012acddb155b8ee8f";
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

  # Environment vars used for building certain configurations
  DISABLE_WARNING_AS_ERROR = "1";
  PORTABLE = "1";
  USE_SSE = "1";
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
