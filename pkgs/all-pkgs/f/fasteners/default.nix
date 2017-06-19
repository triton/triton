{ stdenv
, buildPythonPackage
, fetchPyPi

, monotonic
, six
}:

let
  version = "0.14.1";
in
buildPythonPackage {
  name = "fasteners-${version}";

  src = fetchPyPi {
    package = "fasteners";
    inherit version;
    sha256 = "427c76773fe036ddfa41e57d89086ea03111bbac57c55fc55f3006d027107e18";
  };

  propagatedBuildInputs = [
    monotonic
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
