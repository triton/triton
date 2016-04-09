{ lib
, hostSystem
}:

let
  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    import <nix/fetchurl.nix> {
      name = file;
      url = "https://ipfs.wak.io/ipfs/${multihash}";
      #urls = [
      #  "http://127.0.0.1/ipfs/${multihash}"
      #  "http://127.0.0.1:8080/ipfs/${multihash}"
      #  "https://pub.wak.io/nixos/bootstrap/${hostSystem}/${nix-hash}/${file}"
      #  "https://ipfs.wak.io/ipfs/${multihash}"
      #  "https://gateway.ipfs.io/ipfs/${multihash}"
      #];
      inherit sha256 executable;
    };
in
if [ hostSystem ] == lib.platforms.x86_64-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "gn9dm0jsqjwk08k4s4xakcanikffmrw2";
    multihash = "QmQJUUmN6bBcVyEGCfgyurwee4vChZR7jKRoXS3zj8CVnM";
    sha256 = "0j42mh47gb3501yfz8pr6hpxqrf7fzfl170fmypmi7f9x0p6i3x2";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "gn9dm0jsqjwk08k4s4xakcanikffmrw2";
    multihash = "QmRscqmDa1C6c1rRWPWnd9YLYmDgo8gzwm1fkLFiKmMxPJ";
    sha256 = "e034a412ec2d95ec06faa08a86d46cae4f573c513744529a31fef654ca72ef11";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else if [ hostSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "is0wjld2l6far986w69bmzhl5f58j1fh";
    multihash = "QmemDcocPBMvmzmmf7cCTBHNt9uuc5Lfzo1G3uBqn84B7K";
    sha256 = "14l4rzv35d2kqsj8d69gpnhf4wxk63d53k2zchgsjk6sgzm4gfgx";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "is0wjld2l6far986w69bmzhl5f58j1fh";
    multihash = "QmVEu5kSfvk3FHymC7WwTaxXv3qLhaQb9aGhUvaZZSVKSA";
    sha256 = "80c7a35e4d80425393ba711064080b68a2f393df694b604674804848a90f5d97";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"
