{ stdenv
, compiler
}:

stdenv.mkDerivation {
  name = "cc-wrapper-bootstrap";

  buildCommand = ''
    mkdir -p "''${outputs[out]}"/nix-support
    sed "s,@compiler@,${compiler},g" '${./setup-hook-bootstrap.sh}' >"''${outputs[out]}"/nix-support/setup-hook
    ln -sv "${compiler}"/bin "''${outputs[out]}"
  '';

  preferLocalBuild = true;
}
