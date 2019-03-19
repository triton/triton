{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    boolEn;

  version = "0.1.2";
in
stdenv.mkDerivation rec {
  name = "textencode-${version}";

  src = fetchurl {
    url = "https://github.com/triton/textencode/releases/download/v${version}/${name}.tar.xz";
    multihash = "Qma56mUtqDVoTqUjmEmUbkTJLdSUoXpp6i4Tv1GYWJjQf4";
    sha256 = "c67e1c80eb5a58c5878bf88d56e98ae2ad1109e475e37da309e56e971b7ad532";
  };

  configureFlags = [
    "--${boolEn doCheck}-tests"
  ];

  doCheck = false;

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
