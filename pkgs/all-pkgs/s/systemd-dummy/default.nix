{ stdenv
}:

stdenv.mkDerivation {
  name = "systemd-dummy-245";

  buildCommand = ''
    mkdir -p "$out"/lib/pkgconfig
    cp '${./udev.pc}' "$out"/lib/pkgconfig/udev-uninstalled.pc
    cp '${./systemd.pc}' "$out"/lib/pkgconfig/systemd-uninstalled.pc
  
    mkdir -p "$out"/nix-support
    cp '${./setup-hook.sh}' "$out"/nix-support/setup-hook
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
