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
      version = "0.16.18";
      sha256_alpha = "3df665b88773093ed9eb91590b3eb9c70e79eaf986bb8bfe34d01d0a52071ca6";
      sha256_headless = "a3ca99ae869a468ab58fe3c15db51b9d26ef135f2f433dc994f28660485c4990";
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
    mkdir -pv "$out"/{bin,share/factorio/}
  '' + optionalString (type != "headless") ''
    mkdir -pv "$out"/share/doc
    mv -v doc-html/ "$out"/share/doc/factorio/
  '' + ''
    mv -v data/ "$out"/share/factorio/

    sed ${./factorio.sh} \
      -e "s,@sed@,$(dirname "$(type -tP sed)")," \
      -e "s,@factorio@,$out/share/factorio/bin/x64/factorio," \
      > $out/bin/factorio
    chmod 755 $out/bin/factorio

    cp -rv bin/ "$out"/share/factorio/

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      "$out"/share/factorio/bin/x64/factorio
    patchelf \
      --set-rpath "$(echo -n "$libs" | tr ' ' '\n' | sed 's,.*,\0/lib,' | tr '\n' ':')" \
      "$out"/share/factorio/bin/x64/factorio

    if ldd "$out"/share/factorio/bin/x64/factorio |
           grep -v 'libGL.so.1' | grep -q 'not found'; then
      ldd "$out"/share/factorio/bin/x64/factorio
      exit 1
    fi

    cat > "$out"/share/factorio/config-path.cfg <<'EOF'
    config-path=~/.local/share/factorio
    use-system-read-write-data-directories=false

    EOF
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
