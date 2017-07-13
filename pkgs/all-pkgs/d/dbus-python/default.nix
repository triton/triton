{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, dbus
, dbus-glib
}:

let
  version = "1.2.4";
in
buildPythonPackage {
  name = "dbus-python-${version}";

  src = fetchPyPi {
    package = "dbus-python";
    inherit version;
    sha256 = "e2f1d6871f74fba23652e51d10873e54f71adab0525833c19bad9e99b1b2f9cc";
  };

  buildInputs = [
    dbus
    dbus-glib
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
