{ lib
, fetchurl
, hostSystem
}:

let
  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    fetchurl {
      name = file;
      inherit multihash sha256 executable;
    };
in
if [ hostSystem ] == lib.platforms.x86_64-linux || [ hostSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "f219whihglbg08g4f0505b7hdcrd6ahf";
    multihash = "QmQQZ4dTqXxss4MpjiyoAKKeKZvSHYKsysR9je9Sn1ckgL";
    sha256 = "e5d220eacbbac7e11e2cf1535080aa1ce713d50bbb2f949c587f7f5a86264048";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "f219whihglbg08g4f0505b7hdcrd6ahf";
    multihash = "QmdmT6PVfJHaRrw6R7Hq6rdpca8GwaU7mgFxD78s9BpHeC";
    sha256 = "7f143fbc300a5c017be65bb19edcbcf02d7a09d33af4d10545aee05ed9143a0b";
  };
} else if [ hostSystem ] == lib.platforms.powerpc64le-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "gx3nsbw7l24z851s1ry1zj45y21fcjjv";
    multihash = "QmZ1iQEgpf2kUee456XBdWa6eMpgyGRYBabfvQpG3UoYLv";
    sha256 = "7d979b4b03a1f12076df1030b44ab56a39b56f087553e47f819c2ef7599f0511";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "gx3nsbw7l24z851s1ry1zj45y21fcjjv";
    multihash = "QmdCsJdzoZ214wiNG5mVfiB5cjFA6QvFsbbic8QR8YaSok";
    sha256 = "f1e879508797be294a77af3919b8266682ce5523db0ae6b669a6ba296a1d2881";
  };
} else
  throw "Unsupported System ${hostSystem}"
