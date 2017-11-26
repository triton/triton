{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, html5lib
, six
}:

let
  version = "2.1.1";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "760a9368002180fb8a0f4ea48dc6275378e6f311c39d0236d7b904fca1f5ea0d";
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
