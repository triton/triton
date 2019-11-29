{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
}:

let
  version = "0.52.0";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "99efa0d314cc0cc5ae92176f6d0681ebd4e9e4cace6fb96adfab86a5969c1033";
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
