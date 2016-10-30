{ stdenv
, cmake
, fetchgit
, pythonPackages
, ninja

, apt
, audit_lib
, aws-sdk-cpp
, beecrypt
, boost
, bzip2
, cpp-netlib
, cryptsetup
, db
, dpkg
, file
, gflags
, glog
, iptables
, libgcrypt
, libgpg-error
, lvm2
, lz4
, ncurses
, openssl
, popt
, readline
, rocksdb
, rpm
, sleuthkit
, snappy
, systemd_lib
, thrift
, util-linux_lib
, xz
, yara
, zlib
}:

let
  version = "2.0.0";
in
stdenv.mkDerivation {
  name = "osquery-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/facebook/osquery";
    rev = "refs/tags/${version}";
    sha256 = "9bc85a972801beaacb8d89fc0489f1b2504f4fbe179dff0e2afb604f930a4cb7";
  };

  nativeBuildInputs = [
    cmake
    pythonPackages.jinja2
    pythonPackages.python
    ninja
  ];

  buildInputs = [
    apt
    audit_lib
    aws-sdk-cpp
    beecrypt
    boost
    bzip2
    cpp-netlib
    cryptsetup
    db
    dpkg
    file
    gflags
    glog
    iptables
    libgcrypt
    libgpg-error
    lvm2
    lz4
    ncurses
    openssl
    popt
    readline
    rocksdb
    rpm
    sleuthkit
    snappy
    systemd_lib
    thrift
    util-linux_lib
    xz
    yara
    zlib
  ];

  postPatch = ''
    grep -q '\-Qunused-arguments' CMakeLists.txt
    sed -i '/-Qunused-arguments/d' CMakeLists.txt

    grep -q 'boost_.*-mt' osquery/CMakeLists.txt
    grep -q 'rocksdb_lite' osquery/CMakeLists.txt
    sed \
      -e 's,boost_\(.*\)-mt,boost_\1,g' \
      -e 's,rocksdb_lite,rocksdb,g' \
      -i osquery/CMakeLists.txt
  '';

  OSQUERY_PLATFORM = "Linux;NixOS";

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
