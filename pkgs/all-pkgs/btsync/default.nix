{ stdenv
, fetchurl
, patchelf
}:

let
  inherit (stdenv.lib)
    makeSearchPath;
in

stdenv.mkDerivation rec {
  name = "btsync-${version}";
  version = "2.3.7";

  src  = fetchurl {
    url  = "https://download-cdn.getsync.com/${version}/"
      + "linux-x64/BitTorrent-Sync_x64.tar.gz";
    sha256 = "a15d13f7daf14c9c38b78fd7659e982379c0b8a731d437c661367760f632dcc2";
  };

  nativeBuildInputs = [
    patchelf
  ];

  libPath = makeSearchPath "lib" [
    stdenv.cc.libc
  ];

  sourceRoot = ".";

  installPhase = ''
    install -D -m755 -v btsync $out/bin/btsync
  '';

  preFixup = ''
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      "$out/bin/btsync"
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Automatically sync files via secure, distributed technology";
    homepage = "http://www.bittorrent.com/sync";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
