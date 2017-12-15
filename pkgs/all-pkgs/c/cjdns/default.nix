{ stdenv
, fetchFromGitHub
, nodejs
, python2
, which

, util-linux_lib
}:

let
  version = "20";
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "42b60b266ecf5e0b246afbbea71dabed8222d21e524aed3907e9bba3c5036623";
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
    cp installBin cjdroute makekeys privatetopublic publictoip6 "$out"/bin
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
