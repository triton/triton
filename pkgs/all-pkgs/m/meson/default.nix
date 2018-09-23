{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.48.0";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "ecc6b319d86362d1ae2a64c40738f15dff5921b01cdba5d6506c877e4dd55c61";
  };

  propagatedBuildInputs = [
    glibcLocales
  ];

  postPatch = ''
    # Never mangle our RPATHS
    grep -q 'def fix_rpath(' mesonbuild/scripts/depfixer.py
    sed -i '/def fix_rpath(self, new_rpath)/a\        return' mesonbuild/scripts/depfixer.py

    # Fix build command to point to the installed meson
    grep -q 'def get_build_command(' mesonbuild/environment.py
    sed -i "/def get_build_command(/a\        return ['$out/bin/meson']" mesonbuild/environment.py
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
