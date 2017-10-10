{ stdenv
, buildPythonPackage
, fetchPyPi
, pythonOlder
, setuptools-scm

, acl
, llfuse
, lz4
, msgpack-python
, openssl
}:

let
  version = "1.1.0";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "b40c1120c480a8235ce403b8e6e7abf1377458896f438eafce60f54916789e6f";
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
    llfuse
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
