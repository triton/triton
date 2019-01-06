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
if [ hostSystem ] == lib.platforms.x86_64-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "84md38hwv6v4vy0g7cdccnw4x87nkf6i";
    multihash = "QmQ5isT1tEmJhuQ6KNPdtamANEcppBDhv3EyAZE7PHYj1p";
    sha256 = "0ks3flp1kl2dgakzmrj2rw81r54j7wkbm2g176lqki1syzi9wd1c";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "84md38hwv6v4vy0g7cdccnw4x87nkf6i";
    multihash = "QmVwrewK92FSgVPkbHbSL7V4UnYfyVvjA9mWkfJAudvGDH";
    sha256 = "f11d55d5cf13189186c9dab09d887a14dd8a6c749178bbcad634b6cfbece92a8";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else if [ hostSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "794m4bqyvkniwy14axhbvvlwn0nfkvgg";
    multihash = "Qma8NRuL2omkHsjqYv7wYFqYJ5gVFsxe3C73iVpzQEKREV";
    sha256 = "0m2jamdl5q86p7540g5bsb9g9dgxr3nq4a75rzchlm8ich6cljca";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools.tar.xz";
    nix-hash = "794m4bqyvkniwy14axhbvvlwn0nfkvgg";
    multihash = "QmWq525ugaE6MWjVMCz8xUjxxGa9nLdw9ibwxH8b1qJdr6";
    sha256 = "86774a1d77dec741652a162a3003a3cddfa40cef8b168f3a954c877fe8a81164";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"
