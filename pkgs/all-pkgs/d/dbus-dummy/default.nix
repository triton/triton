{ stdenv
}:

stdenv.mkDerivation {
  name = "dbus-dummy";

  buildCommand = ''
    mkdir -p "$out"/lib/pkgconfig
    cp '${./dbus-1.pc}' "$out"/lib/pkgconfig/dbus-1-uninstalled.pc
  
    mkdir -p "$out"/nix-support
    cp '${./setup-hook.sh}' "$out"/nix-support/setup-hook
  '';
}
