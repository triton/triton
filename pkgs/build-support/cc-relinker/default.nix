{ stdenv }:
{ tool
, target ? null
}:

tool // (stdenv.mkDerivation {
  name = "${tool.name}-for-${target}";

  pfx = if (tool.target or null) != null then "${tool.target}-" else "";
  newpfx = if target != null then "${target}-" else "";

  buildCommand = ''
    mkdir -p "$out"/bin
    pushd '${tool}'/bin >/dev/null
    set -x
    for tool in *; do
      [ "''${tool:0:''${#pfx}}" = "$pfx" ] || continue
      base="''${tool:''${#pfx}}"
      ln -sv '${tool}'/bin/"$tool" "$out"/bin/"$newpfx$base"
    done
    set +x
    popd >/dev/null
  '';
}) // {
  inherit target;
}
