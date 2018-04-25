{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, html5lib
, six
}:

let
  version = "2.1.3";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "eb7386f632349d10d9ce9d4a838b134d4731571851149f9cc2c05a9a837a9a44";
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
