{ stdenv
, fetchurl
, lib
, patchelf
}:

# https://help.resilio.com/hc/en-us/articles/206216855-Sync-2-x-change-log

let
  inherit (lib)
    makeSearchPath;

  libPath = makeSearchPath "lib" [
    stdenv.cc.libc
  ];

  version = "2.6.0";
in
stdenv.mkDerivation rec {
  name = "resilio-${version}";

  src  = fetchurl {
    url  = "https://download-cdn.resilio.com/${version}/"
      + "linux-x64/resilio-sync_x64.tar.gz";
    sha256 = "5f73bfefeedf8e042d483d00aa4af93f09a5b7cbd1efaedcbc3a2b9662578100";
  };

  nativeBuildInputs = [
    patchelf
  ];

  srcRoot = ".";

  installPhase = ''
    install -D -m755 -v rslsync $out/bin/rslsync
  '';

  preFixup = ''
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      "$out/bin/rslsync"
  '';

  dontStrip = true;
  # FIXME
  sourceDateEpochWarn = true;

  meta = with lib; {
    description = "Automatically sync files via secure, distributed technology";
    homepage = https://www.resilio.com/individuals/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
