{ stdenv
, buildPythonPackage
, fetchPyPi

, acl
, lz4
, msgpack-python
, openssl
}:

let
  version = "1.0.7";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "203353a299b6ea0c092a1f23b6bb5414a0b795712c213c68f7a1f4c24be131d1";
  };

  BORG_LZ4_PREFIX = lz4;
  BORG_OPENSSL_PREFIX = openssl;

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
