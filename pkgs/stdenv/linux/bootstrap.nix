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
    nix-hash = "rimjf9i78mfc3k7xzznwgnrrjjbsgsii";
    multihash = "QmXzC8ZcvakvH78hqbM1zL5MGJkuFhveNFkrrDdZ6X7CAD";
    sha256 = "1l5b1w4gw92rhvn616i2sb0mykkks5jy67dlicbc0l5vj7cqn2hp";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "rimjf9i78mfc3k7xzznwgnrrjjbsgsii";
    multihash = "QmZNS3KdwfaFuXgmp4aVnQiHARZNeMsTSUek4x7tXQ4nAC";
    sha256 = "04rxw6d0rnhhyan0g8wkn4yrx10bydh2958fpzdfr1d33yy6w85b";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else if [ hostSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "dn8ihwragjgfyjv89l3zflwsby9nffx5";
    multihash = "QmemDcocPBMvmzmmf7cCTBHNt9uuc5Lfzo1G3uBqn84B7K";
    sha256 = "14l4rzv35d2kqsj8d69gpnhf4wxk63d53k2zchgsjk6sgzm4gfgx";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "dn8ihwragjgfyjv89l3zflwsby9nffx5";
    multihash = "Qmc3Nc2pKHcnV3apxRq887cAJBrWU3bsADWMhh5xC1VPgf";
    sha256 = "0n5xvjjvwribhr9vlsm9gf02kyfk3hwd2zl57db8yprbd7x449vg";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"
