{ stdenv
, compiler
}:

assert stdenv.cc == null;
stdenv.mkDerivation {
  name = "cc-wrapper-bootstrap";

  inherit
    compiler;

  buildCommand = ''
    mkdir -p "$out"/nix-support
    substituteAll '${./setup-hook-bootstrap.sh}' "$out"/nix-support/setup-hook
    ln -sv "$compiler"/bin "$out"
  '';

  setupHook = ./setup-hook-bootstrap.sh;

  preferLocalBuild = true;
  allowSubstitutes = false;
}
