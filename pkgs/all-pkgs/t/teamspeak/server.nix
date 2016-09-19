{ stdenv
, fetchurl
, makeWrapper
}:

let
  version = "3.0.13.4";
in
stdenv.mkDerivation {
  name = "teamspeak-server-${version}";

  src = fetchurl {
    urls = [
      "http://dl.4players.de/ts/releases/${version}/teamspeak3-server_linux_amd64-${version}.tar.bz2"
      "http://teamspeak.gameserver.gamed.de/ts3/releases/${version}/teamspeak3-server_linux_amd64-${version}.tar.bz2"
    ];
    sha256 = "cff353c3f395175ba251c787c5ca1cbb3d339be1ae1afe0cf10216a6e81ae5af";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    echo "patching ts3server"
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $(cat $NIX_CC/nix-support/orig-cc)/lib64 \
      --force-rpath \
      ts3server
    cp -v tsdns/tsdnsserver tsdnsserver
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $(cat $NIX_CC/nix-support/orig-cc)/lib64 \
      --force-rpath \
      tsdnsserver
  '';

  installPhase = ''
    # Delete unecessary libraries - these are provided by nixos.
    #rm *.so*

    # Install files.
    mkdir -p $out/lib/teamspeak
    mv -v * $out/lib/teamspeak/

    # Make a symlink to the binary from bin.
    mkdir -p $out/bin/
    ln -sv $out/lib/teamspeak/ts3server $out/bin/ts3server
    ln -s $out/lib/teamspeak/tsdnsserver $out/bin/tsdnsserver

    wrapProgram $out/lib/teamspeak/ts3server \
      --prefix LD_LIBRARY_PATH : $out/lib/teamspeak
    wrapProgram $out/lib/teamspeak/tsdnsserver \
      --prefix LD_LIBRARY_PATH : $out/lib/tsdnsserver
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = with stdenv.lib; {
    description = "TeamSpeak voice communication server";
    homepage = http://teamspeak.com/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
