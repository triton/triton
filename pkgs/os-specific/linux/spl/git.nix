{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-03-17";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "224817e2a81912b46453a96b9eec4804856c801b";
    sha256 = "df8d7ffa57039dc45afae30330d323406a62f52754b7ac13fa13b1a2a8e676dd";
  };

  patches = [ ./patches.patch ];
})
