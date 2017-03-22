{ stdenv
, buildPythonPackage
, fetchPyPi

, cffi
, libsodium
, pycparser
, six
}:

let
  version = "1.1.1";
in
buildPythonPackage {
  name = "pynacl-${version}";

  src = fetchPyPi {
    package = "PyNaCl";
    inherit version;
    sha256 = "a251393a93c4bd85e7a2c1c0e938dc8862743ae27d8def87c32b2888ccca049e";
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
