{ stdenv
, fetchFromGitHub
, which

, ncurses
}:

let
  version = "0.13.1";
in
stdenv.mkDerivation {
  name = "progress-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "Xfennec";
    repo = "progress";
    rev = "v${version}";
    sha256 = "ba6ff3684fd6e70f986c8ec632d57719293ce5f7f82e142fdccd66f3344d9703";
  };
  
  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    ncurses
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
