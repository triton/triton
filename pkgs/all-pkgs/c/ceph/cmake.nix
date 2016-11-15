{ stdenv
, cmake
, fetchgit
, fetchurl
, perl
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
  inherit (stdenv.lib)
    replaceChars;

  sources = (import ./sources.nix)."${channel}";

  inherit (sources)
    version;
in
stdenv.mkDerivation rec {
  name = "ceph-${version}";

  src = if sources ? fetchVersion then
    fetchgit {
      url = "https://github.com/ceph/ceph.git";
      inherit (sources) rev sha256;
      version = sources.fetchVersion;
    }
  else
    fetchurl {
      url = "https://github.com/wkennington/ceph/releases/download/${version}/${name}.tar.xz";
      inherit (sources) sha256;
    };

  nativeBuildInputs = [
    cmake
    perl
    pythonPackages.sphinx
    python2Packages.python
    python2Packages.wrapPython
    python3Packages.cython
    python3Packages.python
    yasm
  ];

  buildInputs = [
    #accelio
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

  postPatch = ''
    # We manually set the version of ceph directly so we don't have to depend on git
    sed \
      -e 's,GIT-NOTFOUND,${version},g' \
      -e 's,GITDIR-NOTFOUND,${replaceChars ["-" "."] ["" ""] version},g' \
      -i cmake/modules/GetGitRevisionDescription.cmake
  '';

  preConfigure = ''
    cmakeFlagsArray+=(
      #"-DCMAKE_INSTALL_SYSCONFDIR=/etc"
      #"-DCMAKE_INSTALL_LOCALSTATEDIR=/var"
      "-DCMAKE_INSTALL_INCLUDEDIR=$lib/include"
      "-DCMAKE_INSTALL_LIBDIR=$lib/lib"
    )
  '';

  cmakeFlags = [
    #"-DWITH_SPDK=ON"
    #"-DWITH_XIO=ON"  # Broken build
    "-DHAVE_BABELTRACE=OFF"
    "-DDEBUG_GATHER=OFF"
    #"-DHAVE_LIBZFS=ON"  # Broken build and broken for using anyway
    "-DWITH_TESTS=OFF"
    #"-DWITH_FIO=ON"
    "-DWITH_SYSTEMD=ON"
    "-DWITH_LTTNG=OFF"
    "-DWITH_SYSTEM_BOOST=ON"

    "-DBUILD_SHARED_LIBS=ON"
    "-DXFS_INCLUDE_DIR=${xfsprogs_lib}/include"
    "-DKEYUTILS_INCLUDE_DIR=${keyutils}/include"
  ];

  makeFlags = [
    "VERBOSE=1"
  ];

  # Ensure we have the correct rpath already to work around
  # a broken patchelf.
  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
  '';

  postInstall = ''
    # Move python libraries to lib
    mv "$out"/lib/python* "$lib"/lib
    rmdir "$out"/lib

    # Bring in lib as a native build input
    mkdir -p "$out"/nix-support
    echo "$lib" > "$out"/nix-support/propagated-native-build-inputs
  '';

  preFixup = ''
    wrapPythonPrograms "$out"/bin
  '';
  
  outputs = [
    "out"
    "lib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
