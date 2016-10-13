{ stdenv
, fetchFromGitHub
, nodejs
, python2
, which

, util-linux_lib
}:

let
  version = "18";
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "64bf9d4ef8e6ce8d825f53d85e0142b00acfd6b3565bc1244c333a65d8de30a5";
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
