{ stdenv
, fetchFromGitHub
}:

let
  date = "2017-09-21";
  rev = "3a10df60133644b23d6e73196afdf15f41958da6";
in
stdenv.mkDerivation rec {
  name = "utf8proc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "JuliaLang";
    repo = "utf8proc";
    inherit rev;
    sha256 = "ab2e18be2531838cf2df86e68a778d964862a2de9771684c6d491762dd9d8110";
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
