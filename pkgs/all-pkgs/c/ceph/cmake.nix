{ stdenv
, cmake
, fetchurl
, perl
, python2Packages
, python3Packages
, yasm

, boost_1-65
, boost
, curl
, expat
, fcgi
, fuse_2
, gperf
, jemalloc
, keyutils
, leveldb
, libaio
, libatomic_ops
, lz4
, nspr
, nss
, openldap
, openssl
, parted
, rdma-core
, rocksdb
, snappy
, systemd_lib
, util-linux_lib
, xfsprogs_lib
, zlib

, channel
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString
    replaceChars
    versionAtLeast
    versionOlder;

  sources = (import ./sources.nix)."${channel}";

  inherit (sources)
    version;

  src = fetchurl {
    url = "https://github.com/wkennington/ceph/releases/download/${version}/ceph-${version}.tar.xz";
    inherit (sources) sha256;
  };

  cephDisk = python3Packages.buildPythonPackage {
    name = "ceph-disk-${version}";

    inherit src;

    pythonPath = [
      parted
    ];

    prePatch = ''
      cd src/ceph-disk
    '';

    postPatch = ''
      sed -i 's,/bin/\(u\|\)mount,\1mount,g' ceph_disk/main.py
      sed -i 's,/sbin/blkid,blkid,g' ceph_disk/main.py
    '';
  };

  cephVolume = python3Packages.buildPythonPackage {
    name = "ceph-volume-${version}";

    inherit src;

    prePatch = ''
      cd src/ceph-volume
    '';
  };
in
stdenv.mkDerivation rec {
  name = "ceph-${version}";

  inherit src;

  nativeBuildInputs = [
    cmake
    python2Packages.python
    python2Packages.wrapPython
    python3Packages.sphinx
    python3Packages.cython
    python3Packages.python
    yasm
  ] ++ optionals (versionOlder version "12.0.0") [
    perl
  ];

  buildInputs = [
    curl
    expat
    fuse_2
    jemalloc
    keyutils
    leveldb
    libaio
    lz4
    nspr
    nss
    openldap
    openssl
    snappy
    systemd_lib
    util-linux_lib
    xfsprogs_lib
    zlib
  ] ++ optionals (versionOlder version "12.0.0") [
    boost_1-65
    fcgi
    libatomic_ops
  ] ++ optionals (versionAtLeast version "12.0.0") [
    boost
    gperf
    rdma-core
    rocksdb
  ];

  # Needed by the ceph command line
  pythonPath = optionals (versionAtLeast version "12.2.0") [
    python2Packages.prettytable
  ];

  postPatch = ''
    # We manually set the version of ceph directly so we don't have to depend on git
    sed \
      -e 's,GIT-NOTFOUND,${version},g' \
      -e 's,GITDIR-NOTFOUND,${replaceChars ["-" "."] ["" ""] version},g' \
      -i cmake/modules/GetGitRevisionDescription.cmake

    # {PYTHON_LIBRARIES} should be {PYTHON_LIBRARY}
    sed -i 's,PYTHON_LIBRARIES,PYTHON_LIBRARY,g' src/CMakeLists.txt

    # Boost doesn't know how to include python libraries
    sed -i '/find_package(Boost/aLIST(APPEND Boost_LIBRARIES ''${PYTHON_LIBRARY})' CMakeLists.txt
  '' + optionalString (versionOlder version "12.0.0") ''
    # Rocksdb fails with gcc7 with Werror
    sed \
      -e '/-Werror/d' \
      -i src/rocksdb/Makefile \
      -i src/rocksdb/CMakeLists.txt
    sed \
      -e '1i#include <functional>' \
      -i src/rocksdb/util/thread_local.h \
      -i src/rocksdb/utilities/persistent_cache/block_cache_tier_file.h \
      -i src/rocksdb/utilities/persistent_cache/hash_table_evictable.h \
      -i src/os/FuseStore.h
  '' + optionalString (versionAtLeast version "12.0.0") ''
    # Fix for rocksdb api change
    grep -q 'rocksdb::perf_context' src/kv/RocksDBStore.cc
    sed -i 's,rocksdb::perf_context.,rocksdb::get_perf_context()->,g' src/kv/RocksDBStore.cc
  '';

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_INSTALL_INCLUDEDIR=$lib/include"
      "-DCMAKE_INSTALL_LIBDIR=$lib/lib"
    )
  '';

  cmakeFlags = [
    "-DDEBUG_GATHER=OFF"
    "-DWITH_TESTS=OFF"
    "-DWITH_LTTNG=OFF"
    "-DWITH_SYSTEM_BOOST=ON"
    "-DWITH_SYSTEMD=ON"

    "-DXFS_INCLUDE_DIR=${xfsprogs_lib}/include"
  ] ++ optionals (versionOlder version "12.2.0") [
    "-DHAVE_BABELTRACE=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DKEYUTILS_INCLUDE_DIR=${keyutils}/include"
  ] ++ optionals (versionAtLeast version "12.2.0") [
    "-DWITH_LZ4=ON"
    "-DWITH_BABELTRACE=OFF"
    "-DWITH_SYSTEM_ROCKSDB=ON"
  ];

  # Ensure we have the correct rpath already to work around
  # a broken patchelf.
  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib -rpath $(pwd)/lib"
  '';

  postInstall = ''
    # Move python libraries to lib
    mv "$out"/lib/python* "$lib"/lib
    rmdir "$out"/lib

    # Bring in lib as a native build input
    mkdir -p "$out"/nix-support
    echo "$lib" > "$out"/nix-support/propagated-native-build-inputs

    ln -sv "${cephDisk}/bin/ceph-disk" "$out"/bin
    ln -sv "${cephVolume}/bin/ceph-volume" "$out"/bin
  '';

  preFixup = ''
    wrapPythonPrograms "$out"/bin
  '';
  
  outputs = [
    "out"
    "lib"
  ];

  # FIXME
  buildDirCheck = false;

  passthru = {
    disk = cephDisk;
    volume = cephVolume;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
