{ stdenv
, fetchFromGitHub
, python3
, re2c
}:

let
  version = "1.10.0";
in
stdenv.mkDerivation rec {
  name = "ninja-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ninja-build";
    repo = "ninja";
    rev = "v${version}";
    sha256 = "1f26b1d74f1835b5b3185b8ccbf7220b1894acb6f99ffcd9ed4e040daad8ecd3";
  };

  nativeBuildInputs = [
    python3
    re2c
  ];

  buildPhase = ''
    python3 ./configure.py --bootstrap --verbose
  '';

  installPhase = ''
    install -vD 'ninja' "$out/bin/ninja"
  '';

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

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
