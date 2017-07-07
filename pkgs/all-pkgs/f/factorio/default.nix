{ stdenv
, fetchurl
, lib

, alsa-lib
, xorg

, type ? "alpha"
}:

let
  version = "0.15.28";

  sha256s = {
    "alpha" = "c1a94f71e3eef51c6bd07a030b8e0505009be6f4df05554751967c6f1855c558";
    "headless" = "7c9d4307e85e573d1c34cb8e7ef4f884dfd3544a45f84fc9418ddd152f946752";
  };

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "factorio${if type != "" then "-${type}" else ""}-${version}";
  
  # NOTE: You need to login and fetch the tarball manually
  # Then run the script at pkgs/all-pkgs/f/factorio/inject-tar <game-tar>
  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://www.factorio.com/get-download/${version}/${type}/linux64";
    sha256 = sha256s."${type}";
  };

  libs = optionals (type != "headless") [
    alsa-lib
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
  ];

  installPhase = ''
    mkdir -p "$out"/share
  '' + optionalString (type != "headless") ''
    mkdir -p "$out"/share/doc
    mv doc-html "$out"/share/doc/factorio
  '' + ''
    mv data "$out"/share/factorio
    sed ${./factorio.sh} \
      -e "s,@sed@,$(dirname "$(type -tP sed)")," \
      -e "s,@factorio@,$out/bin/x64/factorio," \
      >bin/factorio
    chmod +x bin/factorio
    cp -r bin "$out"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out"/bin/x64/factorio
    patchelf --set-rpath "$(echo -n "$libs" | tr ' ' '\n' | sed 's,.*,\0/lib,' | tr '\n' ':')" "$out"/bin/x64/factorio
    if ldd "$out"/bin/x64/factorio | grep -v 'libGL.so.1' | grep -q 'not found'; then
      ldd "$out"/bin/x64/factorio
      exit 1
    fi
    echo "config-path=~/.local/share/factorio" >> "$out"/config-path.cfg
    echo "use-system-read-write-data-directories=false" >> "$out"/config-path.cfg
  '';

  dontStrip = true;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
