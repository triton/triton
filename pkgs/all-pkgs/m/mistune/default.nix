{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.8.4";
in
buildPythonPackage {
  name = "mistune-${version}";

  src = fetchPyPi {
    package = "mistune";
    inherit version;
    sha256 = "59a3429db53c50b5c6bcc8a07f8848cb00d7dc8bdb431a4ab41920d201d4756e";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
