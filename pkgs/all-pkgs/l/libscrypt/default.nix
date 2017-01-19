{ stdenv
, fetchFromGitHub
}:

let
  version = "1.21";
in
stdenv.mkDerivation {
  name = "libscrypt-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "technion";
    repo = "libscrypt";
    rev = "v${version}";
    sha256 = "6689e8a878ddd772df315ba19ffc7071738a0d839e5081313534516d173ab214";
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
