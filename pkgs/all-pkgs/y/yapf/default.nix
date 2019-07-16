{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.28.0";
in
buildPythonPackage rec {
  name = "yapf-${version}";

  src = fetchPyPi {
    package = "yapf";
    inherit version;
    sha256 = "6f94b6a176a7c114cfa6bad86d40f259bbe0f10cf2fa7f2f4b3596fc5802a41b";
  };

  meta = with lib; {
    description = "A formatter for Python files";
    homepage = https://github.com/google/yapf;
    license = licenses.asl20;
    maintianers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
