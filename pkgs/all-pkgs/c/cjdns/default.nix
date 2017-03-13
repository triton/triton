{ stdenv
, fetchFromGitHub
, nodejs
, python2
, which

, util-linux_lib
}:

let
  version = "19.1";
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "ea9b1d37045c01c1eb6978160a273ce3a00623ad986a73fa8138ca91cd87738c";
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
    installBin cjdroute makekeys privatetopublic publictoip6
    mkdir -p $out/share/cjdns
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
