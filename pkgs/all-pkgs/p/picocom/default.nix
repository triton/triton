{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-04-12";
  rev = "1acf1ddabaf3576b4023c4f6f09c5a3e4b086fb8";
in
stdenv.mkDerivation rec {
  name = "picocom-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "npat-efault";
    repo = "picocom";
    inherit rev;
    sha256 = "00d5678dd17c066aae71908556690c3bfa45b468704c6638fb82a34e704ad35d";
  };
  
  installPhase = ''
    mkdir -p "$out/bin"
    cp picocom "$out/bin"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
