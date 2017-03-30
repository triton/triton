{ stdenv
, buildPythonPackage
, fetchPyPi

, pytz
}:

let
  version = "0.7.4";
in
buildPythonPackage {
  name = "mistune-${version}";

  src = fetchPyPi {
    package = "mistune";
    inherit version;
    sha256 = "8517af9f5cd1857bb83f9a23da75aa516d7538c32a2c5d5c56f3789a9e4cd22f";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
