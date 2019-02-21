{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation {
  name = "build-dir-check";

  setupHook = ./setup-hook.sh;

  unpackPhase = ''
    true
  '';

  buildPhase = ''
    g++ -std=c++17 -O3 -Wall -Wpedantic -Werror "${./main.cc}" -o build-dir-check
  '';

  installPhase = ''
    mkdir -p "$out"/bin
    mv build-dir-check "$out"/bin
  '';

  preFixup = ''
    export PATH="$out/bin:$PATH"
    source "$setupHook"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
