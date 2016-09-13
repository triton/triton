{ stdenv
, fetchFromGitHub

, libbsd
}:

let
  version = "19";
in
stdenv.mkDerivation {
  name = "signify-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "aperezdc";
    repo = "signify";
    rev = "v${version}";
    sha256 = "26d997c29c5214740fd64fa3adebbee36df0514332816e13127f1d5c33c5c849";
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
