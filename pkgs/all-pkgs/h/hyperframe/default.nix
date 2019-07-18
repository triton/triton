{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "5.2.0";
in
buildPythonPackage {
  name = "hyperframe-${version}";

  src = fetchPyPi {
    package = "hyperframe";
    inherit version;
    sha256 = "a9f5c17f2cc3c719b917c4f33ed1c61bd1f8dfac4b1bd23b7c80b3400971b41f";
  };

  meta = with lib; {
    description = "Pure-Python HTTP/2 framing";
    homepage = https://github.com/python-hyper/hyperframe;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
