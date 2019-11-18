{ stdenv
, lib
}:
{ pkg-config }:

let
  inherit (lib)
    concatStringsSep
    flip;

  variable = {
    bootSysDir    = "boot_sys_dir";
    installSysDir = "install_sys_dir";
    runtimeSysDir = "runtime_sys_dir";
  };
  
  args = concatStringsSep " " (map (n: "\"${n}\"") [
    "--define-variable=${variable.bootSysDir}=\${BOOT_SYS_DIR:-/run/booted-system/sw}"
    "--define-variable=${variable.installSysDir}=\${INSTALL_SYS_DIR:-/no-such-path}"
    "--define-variable=${variable.runtimeSysDir}=\${RUNTIME_SYS_DIR:-/run/current-system/sw}"
  ]);
in
stdenv.mkDerivation {
  name = "${pkg-config.name}-wrapped";

  buildCommand = ''
    BIN='${pkg-config.bin}/bin/pkg-config'
    test -e "$BIN"

    mkdir -p "$out"/bin
    sed '${./wrapper.sh.in}' \
      -e 's#@ARGS@#${args}#g' \
      -e "s#@BIN@#$BIN#g" \
      >"$out"/bin/pkg-config
    chmod +x "$out"/bin/pkg-config

    # Verify the wrapper works
    echo "Name: test" >>test.pc
    echo "Description: test" >>test.pc
    echo "Version: 0.1" >>test.pc
    echo "Cflags: -I1" >>test.pc
    source '${./setup-hook.sh}'

    set -x
    test "$("$BIN" --version)" = "$("$out"/bin/pkg-config --version)"
    test -I1 = $("$out"/bin/pkg-config --cflags test.pc)
    test "$INSTALL_SYS_DIR" = "$("$out"/bin/pkg-config --variable=install_sys_dir test.pc)"
    set +x

    ln -sv "${pkg-config.bin}/share" "$out"

    mkdir -p "$out"/nix-support
    cp '${./setup-hook.sh}' "$out"/nix-support/setup-hook
  '';

  passthru = {
    inherit variable;
  };
}
