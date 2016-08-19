{ lib
, hostSystem
}:

let
  mirrors = import ../../build-support/fetchurl/mirrors.nix;

  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    import <nix/fetchurl.nix> {
      name = file;
      url = "${lib.head mirrors.ipfs}/ipfs/${multihash}";
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
    file = "bootstrap-tools.tar.xz";
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
    nix-hash = "66zksl5jd4yq07nlz1p6a2nmlq6qcn60";
    multihash = "QmV7shxYLE3qAe36j72wQHyA2Z5gh18RaVrfEG6HQEKwLQ";
    sha256 = "0niq9636qqfph73qggqky58x1hjq78qfd9mg5ksmmys6sizg63ai";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "66zksl5jd4yq07nlz1p6a2nmlq6qcn60";
    multihash = "QmR4pkiPEjFMdnZj6Z2UbWvZzvwTxyuDVmor1Qicd5j7Ed";
    sha256 = "00b6bwz6ij4734w8fj89gchann6yncz0y2n9wa34b5ixcfzkz0zn";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"
