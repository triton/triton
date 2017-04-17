{ stdenv
, buildPythonPackage
, fetchPyPi

, twisted
}:

let
  version = "0.14.2";
in
buildPythonPackage {
  name = "Nevow-${version}";

  src = fetchPyPi {
    package = "Nevow";
    inherit version;
    sha256 = "7ef8e6147a65a17ef85ef1c017b20126cfb58bdb2ddb730e73fb15a93d205073";
  };

  buildInputs = [
    twisted
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
