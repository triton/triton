{ stdenv
, fetchurl
, lib

, channel
}:

# https://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html

# FIXME
# Requires gcc's libstdc++.so.6
#assert stdenv.cc.isGNU;

let
  inherit (lib)
    makeSearchPath;

  sources = {
    "stable" = {
      version = "32.0.0.142";
      sha256 = "6e422fb3b47b53595842f3788d7b3bddac0f200078f88b7e8eebcfcbb90f673f";
    };
    "beta" = {
      version = "24.0.0.154";
      sha256 = "bd58f3523194c0f63694eef6705b91cc1fbd70ca8b02585e0105c6494f117057";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "flash-player-${source.version}";

  src = fetchurl {
    url =
      if channel == "beta" then
        # FIXME: figure out stable url or use Gentoo's method using the rpm
        "https://fpdownload.adobe.com/pub/labs/flashruntimes/flashplayer/"
          + "linux64/flash_player_ppapi_linux.x86_64.tar.gz"
      else
        "https://fpdownload.adobe.com/pub/flashplayer/pdc/"
          + "${source.version}/flash_player_ppapi_linux.x86_64.tar.gz";
    name = "flash_player_ppapi_linux.${source.version}.x86_64.tar.gz";
    inherit (source) sha256;
  };

  flashPlayerLibs = makeSearchPath "lib" [
    stdenv.cc.cc
    stdenv.cc.libc
  ];

  preUnpack = ''
    mkdir -p src/
    cd src/
    srcRoot="$(pwd)"
  '';

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    install -D -m 644 -v "$srcRoot/libpepflashplayer.so" \
      "$out/lib/PepperFlash/libpepflashplayer.so"
    install -D -m 644 -v "$srcRoot/manifest.json" \
      "$out/lib/PepperFlash/manifest.json"
  '';

  preFixup = ''
    patchelf \
      --set-rpath "$flashPlayerLibs" \
      "$out/lib/PepperFlash/libpepflashplayer.so"
  '';

  postFixup = /* Run some tests */ ''
    # Fail if library contains broken RPATH's
    local TestLib="$out/lib/PepperFlash/libpepflashplayer.so"
    echo "Testing rpath for: $TestLib"
    if [ -n "$(ldd "$TestLib" 2> /dev/null |
               grep --only-matching 'not found' || :)" ] ; then
      echo "ERROR: failed to patch RPATH's for:"
      echo "$TestLib"
      ldd $TestLib
      return 1
    fi
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = with lib; {
    description = "Adobe Flash Player browser plugin";
    homepage = https://www.adobe.com/products/flashplayer.html;
    license = licenses.unfree; # AdobeFlash
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
