{ stdenv
, lib
}:

stdenv.mkDerivation {
  name = "autotools-builder";

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
