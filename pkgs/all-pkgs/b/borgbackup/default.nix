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
  version = "1.1.3";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "cc2a329956dc42e7e461d2f506a28e398c4cc6dc53a67cc2c8a17dcacc4276e7";
  };

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

  postPatch = ''
    sed -i setup.py \
      -e 's,/usr,/non-existant-path,g' \
      -e 's,/opt,/non-existant-path,g'
  '';

  BORG_LZ4_PREFIX = lz4;
  BORG_OPENSSL_PREFIX = openssl;

  disabled = pythonOlder "3.5";

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
