{ stdenv
, buildPythonPackage
, fetchPyPi

, cffi
, libsodium
, pycparser
, six
}:

let
  version = "1.0.1";
in
buildPythonPackage {
  name = "pynacl-${version}";

  src = fetchPyPi {
    package = "PyNaCl";
    inherit version;
    sha256 = "d21d7a7358a85fb9b9ddadfbd1176c40fe199334fe2202881255e77f6d3773f4";
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
