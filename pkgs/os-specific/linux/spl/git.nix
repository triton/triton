{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-06-21";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "5ad98ad0978d43b41180018536ce5efdaa4ea546";
    sha256 = "4ee328238bbb410fb2c12da8c37cbf89d25edb11d1e5e55e5e2d5154f7e0f142";
  };

  patches = [ ./patches.patch ];
})
