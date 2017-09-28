{ stdenv
, fetchurl
, lib

, alsa-lib
, libx11
, libxi
, libxinerama
, libxrandr
, xorg

, channel ? "0.15"
, type ? "alpha"
}:

let
  sources = {
    "0.15" = {
      version = "0.15.35";
      sha256_alpha = "7b8b0b173b34eac9e54e84de2fe03c0114796046088a287343853a15b5802ecb";
      sha256_headless = "33f674097b3fc92a7d6bdda50aa036f847fc2338564e4c32555adbf8f9040995";
    };
  };
  source = sources."${channel}";

  inherit (lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "factorio${if type != "" then "-${type}" else ""}-${source.version}";

  # NOTE: You need to login and fetch the tarball manually
  # Then run the script at pkgs/all-pkgs/f/factorio/inject-tar <game-tar>
  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://www.factorio.com/get-download/${source.version}/"
      + "${type}/linux64";
    sha256 = source."sha256_${type}";
  };

  libs = optionals (type != "headless") [
    alsa-lib
    libx11
    xorg.libXcursor
    libxi
    libxinerama
    libxrandr
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
