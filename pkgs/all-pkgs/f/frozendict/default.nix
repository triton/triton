{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0";
in
buildPythonPackage {
  name = "frozendict-${version}";

  src = fetchPyPi {
    package = "frozendict";
    inherit version;
    sha256 = "4852b8d74173f69bfaaca2dc77b69b0ae85ceddbead80d1954aa250d90e66f32";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
