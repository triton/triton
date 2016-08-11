{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.4.7";
in
buildPythonPackage {
  name = "daemonize-${version}";

  src = fetchPyPi {
    package = "daemonize";
    inherit version;
    sha256 = "c0194e861826be456c7c69985825ac7b79632d8ac7ad4cde8e12fee7971468c8";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
