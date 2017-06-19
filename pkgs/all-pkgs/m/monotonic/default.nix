{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.3";
in
buildPythonPackage {
  name = "monotonic-${version}";

  src = fetchPyPi {
    package = "monotonic";
    inherit version;
    sha256 = "2b469e2d7dd403f7f7f79227fe5ad551ee1e76f8bb300ae935209884b93c7c1b";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
