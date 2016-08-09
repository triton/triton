{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "6.6";
in
buildPythonPackage {
  name = "click-${version}";

  src = fetchPyPi {
    package = "click";
    inherit version;
    sha256 = "cc6a19da8ebff6e7074f731447ef7e112bd23adf3de5c597cf9989f2fd8defe9";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
