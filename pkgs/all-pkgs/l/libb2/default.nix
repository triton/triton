{ stdenv
, lib
, autoreconfHook
, fetchFromGitHub
}:

let
  rev = "e5f2bb51e580fd9e42da86d8943a35af3f19371e";
  date = "2018-03-27";
in
stdenv.mkDerivation {
  name = "libb2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "BLAKE2";
    repo = "libb2";
    inherit rev;
    sha256 = "277e5ce9ef1ce40f21180ab264f10220b47f4394bf6042b0eec34a943ad10c0c";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
