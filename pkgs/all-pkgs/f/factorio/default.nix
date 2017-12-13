{ stdenv
, fetchurl
, lib

, alsa-lib
, libx11
, libxcursor
, libxi
, libxinerama
, libxrandr

, channel
, type ? "alpha"
}:

let
  sources = {
    "0.15" = {
      version = "0.15.40";
      sha256_alpha = "94121fe3437891927a9ecabb4772dd2ed3e9df31b46e0a80abb761803ac245c4";
      sha256_headless = "1041ef61ea4aecd1f425e6030a909f0c349a9c01d1b3324d84a61b1cfef5ba6c";
    };
    "0.16" = {
      version = "0.16.1";
      sha256_alpha = "cf893dc2863b6441034ada7bda84ee0e6eb70c4b40bfdd353c08651270811075";
      sha256_headless = "b3ca5f5676efe06bcd43f71dbf0227011e5d845a366becf3f07a825e7d6f4de3";
    };
  };
  source = sources."${channel}";

  inherit (lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "factorio${if type != "" then "-${type}" else ""}-${source.version}";

  # NOTE: You need to login and fetch the tarball manually. Then run the
  #       script `inject-tar <game-tar>`.
  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://www.factorio.com/get-download/${source.version}/"
      + "${type}/linux64";
    sha256 = source."sha256_${type}";
  };

  libs = optionals (type != "headless") [
    alsa-lib
    libx11
    libxcursor
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
