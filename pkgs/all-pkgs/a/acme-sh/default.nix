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
  version = "2.8.2";

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
    sha256 = "c28f0230249571c8db5dc3c1a91fe9aa0da00a95bdf5602113a1e914370c0a89";
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
