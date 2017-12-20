{ stdenv
, fetchFromGitHub
}:

let
  version = "154";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "44e6a2eb314e1061d5866d7017e654bdd272ebb56c090ec9ddb7d5cdd836b876";
  };

  preBuild = ''
    makeFlagsArray+=(
      "etcprefix=$out"
      "prefix=$out"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
