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
    version = 4;
    owner = "P-H-C";
    repo = "phc-winner-argon2";
    inherit rev;
    sha256 = "2a916746b074633b58faae148da485443b6a7753da200f2ad5c6661dac1017ee";
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
