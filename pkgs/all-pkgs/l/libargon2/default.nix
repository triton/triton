{ stdenv
, fetchFromGitHub
}:

let
  date = "2019-05-20";
  rev = "62358ba2123abd17fccf2a108a301d4b52c01a7c";
in
stdenv.mkDerivation {
  name = "libargon2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "P-H-C";
    repo = "phc-winner-argon2";
    inherit rev;
    sha256 = "ff41a7638218452836e497bb164eb0370f63ff1cd286eb5c86353b5320427997";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "LIBRARY_REL=lib"
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
