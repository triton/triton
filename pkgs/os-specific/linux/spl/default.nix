{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.4";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "0k80xvl15ahbs0mylfl2bd5widxhngpf7dl6zq46s21wk0795jl4";
  };

  patches = [ ./patches.patch ];
})
