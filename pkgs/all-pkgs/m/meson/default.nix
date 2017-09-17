{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, glibcLocales
}:

let
  version = "0.42.1";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "bb74f7aa0baea94f4d4b8502aea43afd45555c8678e618232ea8a2ca6f0f0ede";
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
