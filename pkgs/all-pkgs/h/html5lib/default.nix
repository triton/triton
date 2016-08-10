{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "0.9999999";
in
buildPythonPackage {
  name = "html5lib-${version}";
  
  src = fetchPyPi {
    package = "html5lib";
    inherit version;
    sha256 = "2612a191a8d5842bfa057e41ba50bbb9dcb722419d2408c78cff4758d0754868";
  };

  buildInputs = [
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
