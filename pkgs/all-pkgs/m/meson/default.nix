{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.42.0";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "4ef46250beea2af272a2ab5bdf835dd06e8c8d341c18529d502b5f7be0ac73fe";
  };

  propagatedBuildInputs = [
    glibcLocales
  ];

  # Never mangle our RPATHS
  postPatch = ''
    grep -q 'def fix_rpath(' mesonbuild/scripts/depfixer.py
    sed -i '/def fix_rpath(/a\        return' mesonbuild/scripts/depfixer.py
  '';

  setupHook = ./setup-hook.sh;

  disabled = !isPy3;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
