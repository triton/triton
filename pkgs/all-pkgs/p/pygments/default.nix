{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.2.0";
in
buildPythonPackage {
  name = "Pygments-${version}";

  src = fetchPyPi {
    package = "Pygments";
    inherit version;
    sha256 = "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
