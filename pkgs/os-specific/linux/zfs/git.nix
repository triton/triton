{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-09";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "689f093ebcfa0d57895495050d2b470ed2bef52e";
    sha256 = "fd0742f4743f8449fa29104f2698267dac74eb823e7298c41fef491b7852e4b6";
  };

  patches = [ ./nix-build-git.patch ];

  spl = spl_git;
})
