{ stdenv
, buildPythonPackage
, fetchPyPi

, pbr
, ply
, pyyaml
}:

let
  version = "0.12.4";
in
buildPythonPackage {
  name = "pywbem-${version}";

  src = fetchPyPi {
    package = "pywbem";
    inherit version;
    sha256 = "8bc065f0adb6b6c6c082c663eb5764b841834dbf208952f64cc21f64a252d09f";
  };

  propagatedBuildInputs = [
    pbr
    ply
    pyyaml
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
