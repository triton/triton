{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.43.0";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "c1e05a84e7ba34922562b638dbf85ceec817830ec78c776c8d7954b5bf87c562";
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
