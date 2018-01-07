{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, html5lib
, six
}:

let
  version = "2.1.2";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "38fc8cbebea4e787d8db55d6f324820c7f74362b70db9142c1ac7920452d1a19";
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
