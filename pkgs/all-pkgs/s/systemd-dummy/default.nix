{ stdenv
, systemd_full
}:

stdenv.mkDerivation {
  name = "systemd-dummy";

  version = systemd_full.upstreamVersion;

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
