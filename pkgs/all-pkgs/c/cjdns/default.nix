{ stdenv
, fetchFromGitHub
, nodejs
, python2
, which

, util-linux_lib
}:

let
  version = "20.1";
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "8b6894b1f072bc8be9ad90ad3859654452b2f0491237e8339cb51252f33ef046";
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
