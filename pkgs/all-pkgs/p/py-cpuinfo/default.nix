{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.0.0";
in
buildPythonPackage rec {
  name = "py-cpuinfo-${version}";

  src = fetchPyPi {
    package = "py-cpuinfo";
    inherit version;
    sha256 = "6615d4527118d4ea1db4d86dac4340725b3906aa04bf36b7902f7af4425fb25f";
  };

  meta = with lib; {
    description = "Get CPU info with pure Python";
    homepage = https://github.com/workhorsy/py-cpuinfo;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
