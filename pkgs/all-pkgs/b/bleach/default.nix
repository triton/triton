{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, html5lib
, six
}:

let
  version = "2.0.0";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "b9522130003e4caedf4f00a39c120a906dcd4242329c1c8f621f5370203cbc30";
  };

  propagatedBuildInputs = [
    html5lib
    six
  ];

  postPatch = ''
    sed -i setup.py \
      -i bleach.egg-info/requires.txt \
      -e '/html5lib/ s/\(,\|\)\(!\|>\|<\|=\)\(=\|\)[0-9.]\+//g'
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
