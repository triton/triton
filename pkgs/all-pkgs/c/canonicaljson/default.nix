{ stdenv
, buildPythonPackage
, fetchPyPi

, frozendict
, simplejson
}:

let
  version = "1.1.4";
in
buildPythonPackage {
  name = "canonicaljson-${version}";

  src = fetchPyPi {
    package = "canonicaljson";
    inherit version;
    sha256 = "45bce530ff5fd0ca93703f71bfb66de740a894a3b5dd6122398c6d8f18539725";
  };

  propagatedBuildInputs = [
    frozendict
    simplejson
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
