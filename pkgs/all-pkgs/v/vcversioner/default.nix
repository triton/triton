{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.16.0.0";
in
buildPythonPackage {
  name = "vcversioner-${version}";

  src = fetchPyPi {
    package = "vcversioner";
    inherit version;
    sha256 = "dae60c17a479781f44a4010701833f1829140b1eeccd258762a74974aa06e19b";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
