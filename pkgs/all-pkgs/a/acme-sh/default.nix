{ stdenv
, fetchFromGitHub
, lib
, makeWrapper

, coreutils
, curl
, gawk
, gnugrep
, gnused
, openssl
}:

let
  version = "2.7.9";

  programs = [
    coreutils
    gawk
    gnugrep
    gnused

    curl
    openssl
  ];

  inherit (lib)
    concatStringsSep;

  programsPath = concatStringsSep ":" (map (n: "${n}/bin") programs);
in
stdenv.mkDerivation rec {
  name = "acme.sh-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "Neilpang";
    repo = "acme.sh";
    rev = version;
    sha256 = "ecd7da752f40f51e0613c505a356bb5420d85a13f17faecdac401195cf363bd6";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p "$out"/bin
    cp acme.sh "$out"/bin

    wrapProgram "$out"/bin/acme.sh \
      --set PATH "${programsPath}"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
