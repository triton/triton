{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.48.1";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "ef893e2d64083463fe41f05d683edbe8c44bc187cd9cc66cbc2b1ce399567447";
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
