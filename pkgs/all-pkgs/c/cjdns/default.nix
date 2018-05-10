{ stdenv
, fetchFromGitHub
, nodejs
, python2
, which

, util-linux_lib
}:

let
  version = "20.2";
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "b7ec0051f007ffeadbbbc1e590aa4779c353f4564e5737a153d225f5a11e067a";
  };

  nativeBuildInputs = [
    nodejs
    python2
    which
  ];

  buildInputs = [
    util-linux_lib
  ];

  buildPhase = ''
    bash do
  '';

  installPhase = ''
    mkdir -p "$out"/{bin,share/cjdns}
    cp cjdroute makekeys privatetopublic publictoip6 "$out"/bin
    cp -R contrib tools node_build node_modules $out/share/cjdns
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/cjdelisle/cjdns;
    description = "Encrypted networking for regular people";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
