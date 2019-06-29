{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
}:

let
  version = "0.51.0";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "b9a59a2116836257d53b2b803337e797ab4d11da4a9dfbaa76544b0ec0894dd9";
  };

  postPatch = ''
    # Never mangle our RPATHS
    grep -q 'def fix_rpath(' mesonbuild/scripts/depfixer.py
    sed -i '/def fix_rpath(self, new_rpath)/a\        return' mesonbuild/scripts/depfixer.py

    # Fix build command to point to the installed meson
    grep -q 'def get_build_command(' mesonbuild/environment.py
    sed -i "/def get_build_command(/a\        return ['$out/bin/meson']" mesonbuild/environment.py
  '';

  postInstall = ''
    mkdir -p "$dev"
  '';

  postFixup = ''
    mkdir -p "$dev"/{bin,nix-support}
    ln -sv "$out"/bin/meson "$dev"/bin
    substituteAll '${./setup-hook.sh}' "$dev/nix-support/setup-hook"
  '';

  disabled = !isPy3;

  outputs = [ "out" "dev" ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
