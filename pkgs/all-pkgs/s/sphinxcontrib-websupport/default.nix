{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1.0";
in
buildPythonPackage {
  name = "sphinxcontrib-websupport-${version}";

  src = fetchPyPi {
    package = "sphinxcontrib-websupport";
    inherit version;
    sha256 = "9de47f375baf1ea07cdb3436ff39d7a9c76042c10a769c52353ec46e4e8fc3b9";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
