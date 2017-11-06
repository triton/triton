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
  version = "1.1.2";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "097b2d92d51f570aaea82ab6632481b8235b78d7bbaac9d8164bdfa6bd5b5502";
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
