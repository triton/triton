{ stdenv
, fetchFromGitHub
}:

let
  date = "2017-11-29";
  rev = "b11de0f5c65bcc1b906f85f4df58883b0c133e7b";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "91a55f9b7449d20d9357e9898b38b89a05ffd43ef5b71a188597eea77730b47e";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
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
