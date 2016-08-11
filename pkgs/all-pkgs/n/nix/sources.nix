{ fetchurl
, fetchFromGitHub
}:

{
  "1.11" = rec {
    version = "1.11.2";
    src = fetchurl {
      url = "http://nixos.org/releases/nix/nix-${version}/nix-${version}.tar.xz";
      sha256 = "fc1233814ebb385a2a991c1fb88c97b344267281e173fea7d9acd3f9caf969d6";
    };
  };
  "unstable" = {
    version = "2016-00-00";
    src = fetchFromGitHub {
      owner = "triton";
      repo = "nyx";
      rev = "";
      sha256 = "";
    };
  };
}
