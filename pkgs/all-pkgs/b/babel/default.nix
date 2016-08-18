{ stdenv
, buildPythonPackage
, fetchPyPi

, pytz
}:

let
  version = "2.3.4";
in
buildPythonPackage {
  name = "Babel-${version}";

  src = fetchPyPi {
    package = "Babel";
    inherit version;
    sha256 = "c535c4403802f6eb38173cd4863e419e2274921a01a8aad8a5b497c131c62875";
  };

  propagatedBuildInputs = [
    pytz
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
