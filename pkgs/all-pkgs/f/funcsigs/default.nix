{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
}:

let
  version = "1.0.2";
in
buildPythonPackage {
  name = "funcsigs-${version}";

  src = fetchPyPi {
    package = "funcsigs";
    inherit version;
    sha256 = "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50";
  };

  # Backport from Python 3.3
  disabled = isPy3;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
