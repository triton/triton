{ stdenv
, fetchFromGitHub
}:

let
  version = "2.2";
in
stdenv.mkDerivation rec {
  name = "picocom-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "npat-efault";
    repo = "picocom";
    rev = version;
    sha256 = "8e03bbacc32f48dc94703335b4375e257c48b0166f9d32b2a5009977a7554f17";
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
