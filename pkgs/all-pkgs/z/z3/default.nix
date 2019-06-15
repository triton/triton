{ stdenv
, fetchFromGitHub
, lib
, python3

, gmp
}:

let
  version = "4.8.5";
in
stdenv.mkDerivation rec {
  name = "z3-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "Z3Prover";
    repo = "z3";
    rev = "Z3-${version}";
    sha256 = "9b6ed829a89cd1810acf40d5ab35037b6adefb5d6854ccaf0c60e65ec4636f0a";
  };

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    gmp
  ];

  configurePhase = ''
    prefix="$dev"
    python3 scripts/mk_make.py --prefix="$prefix" --gmp
  '';

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
    cd build
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$bin"
    mv "$dev"/bin "$bin"

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
