{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.45.1";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "24602d6cf8f080a7ddf72007ef61ea1dbf3a56562c3c87c1b887af9648ef9394";
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
