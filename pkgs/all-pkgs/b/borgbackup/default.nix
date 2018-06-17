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
  version = "1.1.6";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "a1d2e474c85d3ad3d59b3f8209b5549653c88912082ea0159d27a2e80c910930";
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
