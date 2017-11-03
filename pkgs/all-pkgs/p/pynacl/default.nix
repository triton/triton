{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cffi
, libsodium
, pycparser
, six
}:

let
  version = "1.2.0";
in
buildPythonPackage {
  name = "pynacl-${version}";

  src = fetchPyPi {
    package = "PyNaCl";
    inherit version;
    sha256 = "45c5bcdf8ddefe2e9381f5d37fe778bbda6991fe7004e0b1ea3570df2fc07207";
  };

  propagatedBuildInputs = [
    cffi
    six
  ];

  buildInputs = [
    libsodium
  ];

  # Make sure we use the system libsodium
  postPatch = ''
    sed -i '/def use_system():/a\    return True' setup.py
  '';

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Python binding to the Networking and Cryptography (NaCl) library";
    homepage = https://pypi.python.org/pypi/PyNaCl;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
