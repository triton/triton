{ lib
, targetSystem
}:

let
  mirrors = import ../../build-support/fetchurl/mirrors.nix;

  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    import <nix/fetchurl.nix> {
      name = file;
      url = "${lib.head mirrors.ipfs-cached}/ipfs/${multihash}";
      inherit sha256 executable;
    };
in
if [ targetSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "chipd0431kk7rs4n0qjdjlkq0g0chvk5";
    multihash = "QmbZdPv27g6b3oKwoGKKK94wZm5y7JsCd2e29oiAYGev9f";
    sha256 = "1j0vjxwj84j6f1iyi4j2ps6pnbycw3c99z161fj19727kyvajj02";
    executable = true;
  };

  bootstrap-tools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "chipd0431kk7rs4n0qjdjlkq0g0chvk5";
    multihash = "Qmf3ZLJTsBUp24eLxtZo9o79wv4x8KuYabtepAuR5soiVj";
    sha256 = "1mxsc3am1fdmpi4izzashmphm3abl6zhs5irr8yh4nx5cxyy791h";
  };

  isGNU = true;
} else
  throw "Unsupported System ${targetSystem}"
