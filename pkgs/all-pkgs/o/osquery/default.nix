{ stdenv
, cmake
, fetchgit
, pythonPackages
, ninja

, apt
, audit_lib
, augeas
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
, libxml2
, linenoise-ng
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
  version = "2.2.1";
in
stdenv.mkDerivation {
  name = "osquery-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/facebook/osquery";
    rev = "refs/tags/${version}";
    sha256 = "161336e8df16ba466ff7232de3da67367a20e9c2bab44fb259ce3b00b2332635";
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
    augeas
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
    libxml2
    linenoise-ng
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
    set -x
    grep -q '\-Qunused-arguments' CMakeLists.txt
    sed -i '/-Qunused-arguments/d' CMakeLists.txt

    grep -q '\-stdlib=libstdc++' CMakeLists.txt
    sed -i 's, -stdlib=libstdc++,,g' CMakeLists.txt

    grep -q 'boost_.*-mt' osquery/CMakeLists.txt
    grep -q 'rocksdb_lite' osquery/CMakeLists.txt
    sed \
      -e 's,boost_\(.*\)-mt,boost_\1,g' \
      -e 's,rocksdb_lite,rocksdb,g' \
      -i osquery/CMakeLists.txt
    set +x
  '';

  preConfigure = ''
    mkdir bin
    echo "#! ${stdenv.shell}" >> bin/git
    echo "echo ${version}" >> bin/git
    chmod +x bin/git
    export PATH="$(pwd)/bin:$PATH"
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
