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
  version = "2.8.1";

  programs = [
    coreutils
    gawk
    gnugrep
    gnused

    curl
    openssl
  ];

  programsPath = lib.concatStringsSep ":" (map (n: "${n}/bin") programs);
in
stdenv.mkDerivation rec {
  name = "acme.sh-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "Neilpang";
    repo = "acme.sh";
    rev = version;
    sha256 = "2c35fd4495ecab35003ad3982267215b0597f69d671f3cb2f7df350d82025291";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p "$out"/bin
    cp acme.sh "$out"/bin

    wrapProgram "$out"/bin/acme.sh \
      --prefix PATH : "${programsPath}"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
