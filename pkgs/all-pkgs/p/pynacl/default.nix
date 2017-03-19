{ stdenv
, buildPythonPackage
, fetchPyPi

, cffi
, libsodium
, pycparser
, six
}:

let
  version = "1.1.0";
in
buildPythonPackage {
  name = "pynacl-${version}";

  src = fetchPyPi {
    package = "PyNaCl";
    inherit version;
    sha256 = "37f3c9cfd144b7f92d50e2dcdc02fbfc222f8faba0986bf71cffbba34c57cd10";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
