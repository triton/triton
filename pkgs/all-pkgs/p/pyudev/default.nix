{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "0.21.0";
in
buildPythonPackage {
  name = "pyudev-${version}";

  src = fetchPyPi {
    package = "pyudev";
    inherit version;
    sha256 = "094b7a100150114748aaa3b70663485dd360457a709bfaaafe5a977371033f2b";
  };

  propagatedBuildInputs = [
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
