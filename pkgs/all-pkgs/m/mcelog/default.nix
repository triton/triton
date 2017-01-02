{ stdenv
, fetchFromGitHub
}:

let
  version = "146";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "8cfac41a60956674aa6ddd9ae10b4ffa2b480708aedf42f77e889fe5add534a2";
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
