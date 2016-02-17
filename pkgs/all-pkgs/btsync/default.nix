{ stdenv, fetchurl, patchelf }:

with {
  inherit (stdenv)
    isFreeBSD
    isLinux
    system;
  inherit (stdenv.lib.platforms)
    x86_64-freebsd
    x86_64-linux;
};

let
  arch =
    if (system == "x86_64-freebsd"
       || system == "x86_64-linux") then
      "x64"
    else
      null;
  platform =
    if isFreeBSD then
      "freebsd"
    else if isLinux then
      "linux"
    else
      null;
  libPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.libc
  ];
in
stdenv.mkDerivation rec {
  name = "btsync-${version}";
  version = "2.3.1";

  src  = fetchurl {
    url  = "https://download-cdn.getsyncapp.com/${version}/"
         + "${platform}-${arch}/BitTorrent-Sync_${arch}.tar.gz";
    sha256 =
      if system == "x86_64-freebsd" then
        "1ldhi0ydpxdbpd0ak5c3zv93wif5sqsgfj4ggav2b0djm76alxgb"
      else if system == "x86_64-linux" then
        "17dzyfy6jjzrsf923pmrxmg09nkbdhnq4afcia2d0c1yk6did610"
      else
        null;
  };

  nativeBuildInputs = [
    patchelf
  ];

  sourceRoot  = ".";

  installPhase = ''
    install -vD btsync $out/bin/btsync
  '';

  preFixup = ''
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${libPath} \
      "$out/bin/btsync"
  '';

  dontStrip   = true;

  meta = with stdenv.lib; {
    description = "Automatically sync files via secure, distributed technology";
    homepage = "http://www.bittorrent.com/sync";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-freebsd
      ++ x86_64-linux;
  };
}
