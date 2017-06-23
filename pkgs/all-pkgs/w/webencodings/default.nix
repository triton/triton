{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.1";
in
buildPythonPackage rec {
  name = "webencodings-${version}";

  src = fetchPyPi {
    package = "webencodings";
    inherit version;
    sha256 = "b36a1c245f2d304965eb4e0a82848379241dc04b865afcc4aab16748587e1923";
  };

  meta = with lib; {
    description = "Character encoding for the web";
    homepage = https://github.com/gsnedders/python-webencodings;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
