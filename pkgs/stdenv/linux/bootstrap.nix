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
    nix-hash = "lj2qlkp6jqr43ra6d76ra5v052f4m7mn";
    multihash = "QmNqGF28wVsRGETpKywqahwsyKVYgEg9KxVwPy93hdwNQq";
    sha256 = "1kxcavk1y4wjgwxr6hkbr1zjzr2a390818jr4a3a04n5rmpd542r";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "lj2qlkp6jqr43ra6d76ra5v052f4m7mn";
    multihash = "QmTTouXJEishTwc9pXUHfbjUcb4guhpzWXnXvv1dxrGF9D";
    sha256 = "08amfjv6jvxvrr77kgrnsrlwpm1grzrpmb16vp29rcn9lg7wcmr2";
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
