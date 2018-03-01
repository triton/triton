{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.44.1";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "b060d8115be24d89675b9e0ab7278b970088c48c12a450b30d0d3005d58bc13c";
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

  # Meson tries to find its python executable in the path
  # Since we have a wrapper around the actual executable it fails
  # to run since meson expects to be calling a python executable
  # HACK: Return the python executable directly in this function
  postInstall = ''
    sed -i "/def detect_meson_py_location()/a\    return '$out/bin/.meson-wrapped'" \
      $(find "$out" -name mesonlib.py)
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
