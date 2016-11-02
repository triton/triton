{ stdenv
, buildPythonPackage
, fetchPyPi
, setuptools-scm

, acl
, lz4
, msgpack-python
, openssl
}:

let
  version = "1.0.8";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "6902563c447c4f378ff1a13167f83d15eb60a02316a06368a539b7ff3d88aeb9";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
