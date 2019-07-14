{ stdenv
, fetchFromGitHub

, libbsd
}:

let
  version = "25";
in
stdenv.mkDerivation {
  name = "signify-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aperezdc";
    repo = "signify";
    rev = "v${version}";
    sha256 = "886732a8e8518c4a6ef6e74c56481f74fee95a7ff6b55011b230c4615192964a";
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
