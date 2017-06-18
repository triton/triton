{ stdenv
, fetchurl
, lib

, alsa-lib
, xorg
}:

let
  version = "0.14.23";
in
stdenv.mkDerivation rec {
  name = "factorio-${version}";
  
  # NOTE: You need to login and fetch the tarball manually
  # Then run the script at pkgs/all-pkgs/f/factorio/inject-tar <game-tar>
  src = fetchurl {
    name = "${name}.tar.gz";
    url = "https://www.factorio.com/get-download/${version}/alpha/linux64";
    sha256 = "b532094309e9ebc0c03c0442350948f23113c7d54a973e68210bc71321c8f17a";
  };

  libs = [
    alsa-lib
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
  ];

  installPhase = ''
    mkdir -p "$out"/share/doc
    mv doc-html "$out"/share/doc/factorio
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
