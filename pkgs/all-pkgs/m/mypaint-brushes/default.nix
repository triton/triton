{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "mypaint-brushes-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "jehan";
    repo = "mypaint-brushes";
    rev = "v${version}";
    sha256 = "dd8517fcd0302edfd8485ada8dd8eaa4abb440d51cbd1802f3b461a226c7f07f";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
