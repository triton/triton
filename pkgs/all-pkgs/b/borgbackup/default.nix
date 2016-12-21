{ stdenv
, buildPythonPackage
, fetchPyPi
, pythonOlder
, setuptools-scm

, acl
, lz4
, msgpack-python
, openssl
}:

let
  version = "1.0.9";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "35860840e0429d4bb3acc8b9dd33aa5996a42fb2b678813a982b321a7dba3cb2";
  };

  BORG_LZ4_PREFIX = lz4;
  BORG_OPENSSL_PREFIX = openssl;

  nativeBuildInputs = [
    setuptools-scm
  ];

  buildInputs = [
    acl
    lz4
    openssl
  ];

  propagatedBuildInputs = [
    msgpack-python
  ];

  disabled = pythonOlder "3.4";

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
