{ stdenv
}:

stdenv.mkDerivation {
  name = "systemd-dummy";

  unpackPhase = "true";

  installPhase = "true";

  systemdPcIn = ./systemd.pc.in;
  udevPcIn = ./udev.pc.in;

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
