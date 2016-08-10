{ stdenv
, fetchurl
, patchelf
}:

let
  inherit (stdenv.lib)
    makeSearchPath;

  libPath = makeSearchPath "lib" [
    stdenv.cc.libc
  ];
in
stdenv.mkDerivation rec {
  name = "btsync-${version}";
  version = "2.3.8";

  src  = fetchurl {
    url  = "https://download-cdn.getsync.com/${version}/"
      + "linux-x64/BitTorrent-Sync_x64.tar.gz";
    sha256 = "9e1a63d7e346278f7301f149626013242a3c605db90a645ebe757c164cd1c50a";
  };

  nativeBuildInputs = [
    patchelf
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
