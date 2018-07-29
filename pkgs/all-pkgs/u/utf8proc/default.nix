{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-07-25";
  rev = "f17497653257858941d044ff3bbadbc9b095aa0c";
in
stdenv.mkDerivation rec {
  name = "utf8proc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "JuliaLang";
    repo = "utf8proc";
    inherit rev;
    sha256 = "06f863db9cc92100527c5198597f57634d171d2609276edfab82e41713190dd5";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
