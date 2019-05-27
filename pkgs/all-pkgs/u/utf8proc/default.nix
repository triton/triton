{ stdenv
, fetchFromGitHub
}:

let
  date = "2019-05-14";
  rev = "0dc0fcf8db4ae2ff1971d4f0f86a2d83b14d863d";
in
stdenv.mkDerivation rec {
  name = "utf8proc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "JuliaLang";
    repo = "utf8proc";
    inherit rev;
    sha256 = "d43a3402cbb0ac95ef4129f20bd85290ce315ac06af9cf351522bd006a7f2206";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
