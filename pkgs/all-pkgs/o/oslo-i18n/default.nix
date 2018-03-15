{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babel
, pbr
, six
}:

let
  version = "3.20.0";
in
buildPythonPackage {
  name = "oslo.i18n-${version}";

  src = fetchPyPi {
    package = "oslo.i18n";
    inherit version;
    sha256 = "c3cf63c01fa3ff1b5ae7d6445d805c6bf5390ac010725cf126b18eb9086f4c4e";
  };

  propagatedBuildInputs = [
    babel
    pbr
    six
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
