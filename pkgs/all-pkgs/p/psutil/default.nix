{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.4.0";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "8e6397ec24a2ec09751447d9f169486b68b37ac7a8d794dca003ace4efaafc6a";
  };

  meta = with lib; {
    description = "A process and system utilities module for Python";
    homepage = https://github.com/giampaolo/psutil/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
