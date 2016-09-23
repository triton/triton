{ stdenv
, buildPythonPackage
, fetchPyPi

, html5lib
, six
}:

let
  version = "1.4.3";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "1293061adb5a9eebb7b260516e691785ac08cc1646c8976aeda7db9dbb1c6f4b";
  };

  propagatedBuildInputs = [
    html5lib
    six
  ];

  preConfigure = ''
    sed -i '/html5lib/ s/\(,\|\)\(>\|<\|=\)\(=\|\)[0-9.]\+//g' setup.py bleach.egg-info/requires.txt
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
