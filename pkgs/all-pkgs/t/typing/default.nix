{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.6.2";
in
buildPythonPackage {
  name = "typing-${version}";

  src = fetchPyPi {
    package = "typing";
    inherit version;
    sha256 = "d514bd84b284dd3e844f0305ac07511f097e325171f6cc4a20878d11ad771849";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
