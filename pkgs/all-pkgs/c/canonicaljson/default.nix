{ stdenv
, buildPythonPackage
, fetchPyPi

, frozendict
, simplejson
}:

let
  version = "1.1.3";
in
buildPythonPackage {
  name = "canonicaljson-${version}";

  src = fetchPyPi {
    package = "canonicaljson";
    inherit version;
    sha256 = "06fe8676dbba4289d846f0699324297e1fd9bb7f2cb9964d69f364a0d2fca0e0";
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
