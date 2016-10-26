{ stdenv
, fetchurl
}:

# https://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html

# Requires gcc's libstdc++.so.6
assert stdenv.cc.isGNU;

let
  inherit (stdenv.lib)
    makeSearchPath;

  version = "23.0.0.205";
in
stdenv.mkDerivation rec {
  name = "flash-player-${version}";

  src = fetchurl {
    url = "https://fpdownload.adobe.com/pub/flashplayer/pdc/${version}/"
      + "flash_player_ppapi_linux.x86_64.tar.gz";
    name = "flash_player_ppapi_linux.${version}.x86_64.tar.gz";
    sha256 = "5d1fd6f9a598fe901890dd02f5230b705f1c992703a24f62c93c7725c335b90e";
  };

  flashPlayerLibs = makeSearchPath "lib" [
    stdenv.cc.cc
    stdenv.libc
  ];

  postUnpack = ''
    sourceRoot="$(pwd)"
  '';

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    install -D -m 644 -v "$sourceRoot/libpepflashplayer.so" \
      "$out/lib/PepperFlash/libpepflashplayer.so"
    install -D -m 644 -v "$sourceRoot/manifest.json" \
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

  meta = with stdenv.lib; {
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
