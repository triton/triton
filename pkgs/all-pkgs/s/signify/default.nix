{ stdenv
, fetchFromGitHub

, libbsd
}:

let
  version = "23";
in
stdenv.mkDerivation {
  name = "signify-${version}";

  src = fetchFromGitHub {
    version = 4;
    owner = "aperezdc";
    repo = "signify";
    rev = "v${version}";
    sha256 = "3563da3d5a41e08f9de7a10cfa44f914fe75ae4f1405fb660ebbe02b25d1e170";
  };

  buildInputs = [
    libbsd
  ];

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
