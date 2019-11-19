{ stdenv
, fetchFromGitHub
, python3
, re2c
}:

let
  version = "1.9.0";
in
stdenv.mkDerivation rec {
  name = "ninja-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ninja-build";
    repo = "ninja";
    rev = "v${version}";
    sha256 = "c6bac3bb97b0cb6a2ea89eb6c0a16ec8f0a6d8b341e0097468441800a3aa0d6b";
  };

  nativeBuildInputs = [
    python3
    re2c.bin
  ];

  buildPhase = ''
    python3 ./configure.py --bootstrap --verbose
  '';

  installPhase = ''
    install -vD 'ninja' "$out/bin/ninja"
  '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "Small build system with a focus on speed";
    homepage = http://martine.github.io/ninja/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
