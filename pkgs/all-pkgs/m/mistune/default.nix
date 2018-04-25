{ stdenv
, buildPythonPackage
, fetchPyPi

, pytz
}:

let
  version = "0.8.3";
in
buildPythonPackage {
  name = "mistune-${version}";

  src = fetchPyPi {
    package = "mistune";
    inherit version;
    sha256 = "bc10c33bfdcaa4e749b779f62f60d6e12f8215c46a292d05e486b869ae306619";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
