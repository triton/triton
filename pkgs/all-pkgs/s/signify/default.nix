{ stdenv
, fetchFromGitHub

, libbsd
}:

let
  version = "20";
in
stdenv.mkDerivation {
  name = "signify-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "aperezdc";
    repo = "signify";
    rev = "v${version}";
    sha256 = "e4461b7dfd3ff9c306d897466c65991f92e77add3d4be831709f39ef86ad3537";
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
