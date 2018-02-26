{ stdenv
, fetchFromGitHub
, lib
}:

let
  rev = "2f3913f49c4ac7f9bff9224db5178f6f8f0ff3ee";
  date = "2015-08-05";
in
stdenv.mkDerivation rec {
  name = "kashmir-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "Corvusoft";
    repo = "kashmir-dependency";
    inherit rev;
    sha256 = "ec629656e4137a2413bc4794d594a2432758eb8d36ec481a66d280ae3fef3f3c";
  };
  
  installPhase = ''
    mkdir -p "$out"/include
    mv kashmir "$out"/include/
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
