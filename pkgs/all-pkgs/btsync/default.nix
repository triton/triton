{ stdenv
, fetchurl
, patchelf
}:

let
  inherit (stdenv.lib)
    makeLibraryPath;
in

stdenv.mkDerivation rec {
  name = "btsync-${version}";
  version = "2.3.6";

  src  = fetchurl {
    url  = "https://download-cdn.getsync.com/${version}/"
      + "linux-x64/BitTorrent-Sync_x64.tar.gz";
    sha256 = "fac80d415aa44d9f2e027b56cb4fea1aa8770489cffc037b64fd05135fa4d907";
  };

  nativeBuildInputs = [
    patchelf
  ];

  libPath = makeLibraryPath [
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
