{ stdenv
, buildPythonPackage
, fetchPyPi
, pythonOlder
, setuptools-scm

, acl
, libb2
, llfuse
, lz4
, msgpack-python
, openssl
, zstd
}:

let
  version = "1.1.5";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "4356e6c712871f389e3cb1d6382e341ea635f9e5c65de1cd8fcd103d0fb66d3d";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  buildInputs = [
    acl
    libb2
    lz4
    openssl
    zstd
  ];

  propagatedBuildInputs = [
    msgpack-python
    llfuse
  ];

  BORG_LIBB2_PREFIX = libb2;
  BORG_LIBLZ4_PREFIX = lz4;
  BORG_LIBZSTD_PREFIX = zstd;
  BORG_OPENSSL_PREFIX = openssl;

  postPatch = ''
    # Remove bundling
    rm -r src/borg/algorithms/{blake2,lz4,zstd}

    # Fix searching in /usr or /opt
    sed -i setup.py \
      -e 's,/usr,/non-existant-path,g' \
      -e 's,/opt,/non-existant-path,g'
  '';

  disabled = pythonOlder "3.5";

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
