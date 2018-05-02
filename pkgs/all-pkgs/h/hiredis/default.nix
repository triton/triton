{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-01-06";
  rev = "3d8709d19d7fa67d203a33c969e69f0f1a4eab02";
in
stdenv.mkDerivation rec {
  name = "hiredis-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "redis";
    repo = "hiredis";
    inherit rev;
    sha256 = "314cfd4beff415ff8dffa0d5627a0fd1f675864ae0c671dbcebea9a39c354a5f";
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
