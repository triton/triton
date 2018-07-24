{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-05-31";
  rev = "a65537a672de845f3f4530050d1e7bd88d51ac67";
in
stdenv.mkDerivation rec {
  name = "hiredis-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "redis";
    repo = "hiredis";
    inherit rev;
    sha256 = "1eff991c1f689a14ef29f3906db8e89bdd36e86183709d09bce510ccc0aa7e6c";
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
