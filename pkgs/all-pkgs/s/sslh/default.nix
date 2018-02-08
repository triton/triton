{ stdenv
, fetchFromGitHub

, libcap
, libconfig
, pcre
, systemd_lib
}:

let
  date = "2018-01-27";
  rev = "1a6ba5edc0b4482182ec6603433435ff091f66b6";
in
stdenv.mkDerivation rec {
  name = "sslh-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "yrutschle";
    repo = "sslh";
    inherit rev;
    sha256 = "39d965e17745d8e51492734be2c9a7db8bb0cc1235db0e1f3a045d6ef3fa24a3";
  };

  buildInputs = [
    libcap
    libconfig
    pcre
    systemd_lib
  ];

  makeFlags = [
    "USELIBCAP=1"
    "USESYSTEMD=1"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
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
