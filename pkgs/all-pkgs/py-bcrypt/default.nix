{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.4";
in
buildPythonPackage {
  name = "py-bcrypt-${version}";

  src = fetchPyPi {
    package = "py-bcrypt";
    inherit version;
    sha256 = "5fa13bce551468350d66c4883694850570f3da28d6866bb638ba44fe5eabda78";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
