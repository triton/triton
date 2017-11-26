{ stdenv
, buildPythonPackage
, fetchPyPi

, pytz
}:

let
  version = "0.8.1";
in
buildPythonPackage {
  name = "mistune-${version}";

  src = fetchPyPi {
    package = "mistune";
    inherit version;
    sha256 = "4c0f66924ce28f03b95b210ea57e57bd0b59f479edd91c2fa4fe59331eae4a82";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
