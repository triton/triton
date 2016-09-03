{ stdenv
, fetchFromGitHub
}:

let
  version = "0.13.3";
in
stdenv.mkDerivation rec {
  name = "hiredis-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "redis";
    repo = "hiredis";
    rev = "v${version}";
    sha256 = "20bfce29847c95118ed3a7280e8537036d192cefbd5fca91235b6923dc331a5d";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/redis/hiredis;
    description = "Minimalistic C client for Redis >= 1.2";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
