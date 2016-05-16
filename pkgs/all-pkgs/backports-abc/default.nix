{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "backports_abc-${version}";
  version = "0.4";

  src = fetchPyPi {
    package = "backports_abc";
    inherit version;
    sha256 = "8b3e4092ba3d541c7a2f9b7d0d9c0275b21c6a01c53a61c731eba6686939d0a5";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Backport of recent additions to the 'collections.abc' module";
    homepage = https://github.com/cython/backports_abc;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}