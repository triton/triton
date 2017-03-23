{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.20";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "97ef2b6e2878d84c0126b9f4e608e37a951ca7848e4855a7f7f4437d5c34a72f";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
