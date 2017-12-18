{ stdenv
, lib
}:

stdenv.mkDerivation {
  name = "autotools-builder";

  setupHook = ./setup-hook.sh;

  passthru = {
    commonOutputs = [
      "bin"
      "dev"
      "lib"
      "man"
      "aux"
    ];
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
