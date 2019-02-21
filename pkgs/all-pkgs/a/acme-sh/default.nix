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
  version = "2.8.0";

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
    sha256 = "8849eda79eaa7cf56d2cf4ba2b9bb8c6ecb282ae05687b1ace0e74385a021e48";
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
