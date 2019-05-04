{ stdenv
, fetchFromGitHub
}:

let
  date = "2019-04-17";
  rev = "416749803be5f9d8903c9d95c92153370f890db6";
in
stdenv.mkDerivation rec {
  name = "utf8proc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "JuliaLang";
    repo = "utf8proc";
    inherit rev;
    sha256 = "f17a06dc086ec08d6a9723de4b5e938fdac8f68aa83407a5e69ae55d6171b58e";
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
