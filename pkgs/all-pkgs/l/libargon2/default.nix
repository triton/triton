{ stdenv
, fetchFromGitHub
}:

let
  date = "2017-09-29";
  rev = "54ff100b0717505493439ec9d4ca85cb9cbdef00";
in
stdenv.mkDerivation {
  name = "libargon2-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "P-H-C";
    repo = "phc-winner-argon2";
    inherit rev;
    sha256 = "b2f6707abe57f588c3ded6c576ad3b12ad2edede990187288d49a2b279c179b0";
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
