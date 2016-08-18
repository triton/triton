{ stdenv
, cmake
, fetchgit
, ninja
, pythonPackages
, python2Packages
, python3Packages
, yasm

, accelio
, boost
, curl
, expat
, fcgi
, fuse
, jemalloc
, keyutils
, leveldb
, libaio
, libatomic_ops
, lz4
, nspr
, nss
, openldap
, snappy
, systemd_lib
, util-linux_lib
, xfsprogs_lib
, zlib

, channel ? "10"
}:

let
  inherit ((import ./sources.nix)."${channel}")
    version
    rev
    sha256;
in
stdenv.mkDerivation {
  name = "ceph-${version}";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    inherit rev sha256;
  };

  nativeBuildInputs = [
    cmake
    #ninja
    pythonPackages.sphinx
    python2Packages.python
    python3Packages.cython
    python3Packages.python
    yasm
  ];

  buildInputs = [
    accelio
    boost
    curl
    expat
    fcgi
    fuse
    jemalloc
    keyutils
    leveldb
    libaio
    libatomic_ops
    lz4
    nspr
    nss
    openldap
    snappy
    systemd_lib
    util-linux_lib
    xfsprogs_lib
    zlib
  ];

  cmakeFlags = [
    "-DWITH_XIO=ON"
    "-DHAVE_BABELTRACE=OFF"
    "-DHAVE_LIBZFS=ON"
    "-DWITH_SYSTEMD=ON"

    "-DBUILD_SHARED_LIBS=ON"
    "-DXFS_INCLUDE_DIR=${xfsprogs_lib}/include"
    "-DKEYUTILS_INCLUDE_DIR=${keyutils}/include"
  ];

  makeFlags = [
    "VERBOSE=1"
  ];
  
  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
