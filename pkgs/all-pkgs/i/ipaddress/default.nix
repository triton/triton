{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0.17";
in
buildPythonPackage {
  name = "ipaddress-${version}";

  src = fetchPyPi {
    package = "ipaddress";
    inherit version;
    sha256 = "3a21c5a15f433710aaa26f1ae174b615973a25182006ae7f9c26de151cd51716";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
