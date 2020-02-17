{ stdenv
, fetchzip
}:

let
  rev = "0bf1f7a3e877aff8fb435c3ba8624f35ff985a7e";
  date = "2020-02-06";
in
stdenv.mkDerivation {
  name = "wireguard-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-${rev}.tar.xz";
    multihash = "Qmb7ZZBPbp9jbVCKgf25d5arhMoPztGzZxqYBpRGz2wBNP";
    sha256 = "92bfab1f72ea8be1ec203654dae0ff502fbf7c16f3d153c3ea2ed34b0a724544";
  };

  preConfigure = ''
    cd src
  '';

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "WITH_WGQUICK=yes"
    "WITH_BASHCOMPLETION=yes"
    "WITH_SYSTEMDUNITS=yes"
  ];

  installFlags = [
    "SYSCONFDIR=${placeholder "out"}/etc"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
