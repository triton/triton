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
, socat
}:

let
  version = "2.8.5";

  programs = [
    coreutils
    gawk
    gnugrep
    gnused

    curl
    openssl
    socat
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
    sha256 = "cb1369595376789b6453453650d0d4d69bbb28db7fa714155e402f7f7f10be1b";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p "$out"/bin
    cp -v acme.sh "$out"/bin
    for file in *; do
      if [ -d "$file" ]; then
        cp -rv "$file" "$out"/bin
      fi
    done

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
