{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4";
in
buildPythonPackage {
  name = "zc-lockfile-${version}";

  src = fetchPyPi {
    package = "zc.lockfile";
    inherit version;
    sha256 = "95a8e3846937ab2991b61703d6e0251d5abb9604e18412e2714e1b90db173253";
  };

  meta = with lib; {
    description = "Interprocess locks using file-locking primitives";
    homepage = https://github.com/zopefoundation/zc.lockfile;
    license = licenses.free;  # ZPL 2.1
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
