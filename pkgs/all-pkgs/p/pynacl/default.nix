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
  version = "1.1.2";
in
buildPythonPackage {
  name = "pynacl-${version}";

  src = fetchPyPi {
    package = "PyNaCl";
    inherit version;
    sha256 = "32f52b754abf07c319c04ce16905109cab44b0e7f7c79497431d3b2000f8af8c";
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
