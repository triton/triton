{ stdenv
, fetchFromGitHub
}:

let
  rev = "a402f4116245ce8677b3d9f4f87096b5ccbe26e9";
  date = "2018-02-03";
in
stdenv.mkDerivation {
  name = "libscrypt-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "technion";
    repo = "libscrypt";
    inherit rev;
    sha256 = "a106f4378f475f38e5fd06b43c47f9b71bf8b93834e7f03290699f185079b6cf";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
