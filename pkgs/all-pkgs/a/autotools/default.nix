{ stdenv
, lib

, coreutils
}:

stdenv.mkDerivation {
  name = "autotools-builder";

  buildInputs = [
    coreutils
  ];

  # We need to include parts of coreutils for configure scripts to function
  installAction = ''
    export bindir="$out"/share/autotools/bin
    mkdir -p "$bindir"

    link() {
      local bin="$1"

      if ! type -P "$bin" >/dev/null; then
        echo "Missing $bin from path"
        return 1
      fi

      ln -sv "$(type -P "$bin")" "$bindir"
    }

    link 'expr'
    link 'ls'
    link 'uname'
  '';

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
