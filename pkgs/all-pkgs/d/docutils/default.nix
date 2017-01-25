{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.13.1";
in
buildPythonPackage {
  name = "docutils-${version}";

  src = fetchPyPi {
    package = "docutils";
    inherit version;
    sha256 = "718c0f5fb677be0f34b781e04241c4067cbd9327b66bdd8e763201130f5175be";
  };
  
  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
