{ stdenv
, fetchFromGitHub
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "utf8proc-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "JuliaLang";
    repo = "utf8proc";
    rev = "v${version}";
    sha256 = "a53bfc8c7f2c8fe4c1d3094676761ef0733b6919e38883af9723dd88da209ed8";
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
