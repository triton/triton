{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-03-31";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "e4023e42a8cb0d267870db82f75e23d4efb9fbd9";
    sha256 = "4f3d218d2480dea669e17ad470c975958f8193ac8825875d16b94d2c353a9ced";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
