{ stdenv
, buildPythonPackage
, fetchPyPi

, html5lib
, six
}:

let
  version = "1.5.0";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "978e758599b54cd3caa2e160d74102879b230ea8dc93871d0783721eef58bc65";
  };

  propagatedBuildInputs = [
    html5lib
    six
  ];

  postPatch = ''
    sed -i '/html5lib/ s/\(,\|\)\(!\|>\|<\|=\)\(=\|\)[0-9.]\+//g' setup.py bleach.egg-info/requires.txt
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
