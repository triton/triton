{ stdenv
, fetchFromGitHub

, libcap
, libconfig
, pcre
, systemd_lib
}:

let
  date = "2017-06-12";
  rev = "21f524f71165538dcde9f8de32b9f69385ba0c87";
in
stdenv.mkDerivation rec {
  name = "sslh-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "yrutschle";
    repo = "sslh";
    inherit rev;
    sha256 = "0711e384c336932662bca7f8aec7288498b2da63c63d80d678010a52cc9ca268";
  };

  buildInputs = [
    libcap
    libconfig
    pcre
    systemd_lib
  ];

  makeFlags = [
    "USELIBCONFIG=1"
    "USELIBPCRE=1"
    "USELIBWRAP="
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
