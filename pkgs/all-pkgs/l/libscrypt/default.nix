{ stdenv
, fetchFromGitHub
}:

let
  version = "1.21";
in
stdenv.mkDerivation {
  name = "libscrypt-${version}";

  src = fetchFromGitHub {
    owner = "technion";
    repo = "libscrypt";
    rev = "v${version}";
    sha256 = "451494a4805097f4a9f84093758df8f41f89e7f26d2cb65123e0467919eedd33";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
