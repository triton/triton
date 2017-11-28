{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, openssl
, xorg
}:

let
  version = "2.0.0";
  rev = "0bd448d5ca320dd5fdb9467a7a4a17ff11cce539";
in
stdenv.mkDerivation {
  name = "synergy-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "symless";
    repo = "synergy-core";
    rev = "v${version}-stable";
    sha256 = "eaa7f6e101dca6d6bc9e0fa8771c7e199a401feeed11779d1fada64c398d7fac";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    openssl
    xorg.fixesproto
    xorg.inputproto
    xorg.kbproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.randrproto
    xorg.renderproto
    xorg.xproto
    xorg.xextproto
  ];

  GIT_COMMIT = rev;

  postPatch = ''
    # Don't run or build tests
    sed -i '/add_subdirectory(test)/d' src/CMakeLists.txt
  '';

  installPhase = ''
    mkdir -p "$out"

    mv -v bin "$out"

    cd ../synergy-core-*

    mkdir -p "$out"/share/man/man1
    mv -v doc/synergyc.man "$out"/share/man/man1/synergyc.1
    mv -v doc/synergys.man "$out"/share/man/man1/synergys.1

    mkdir -p "$out"/etc
    cp -v doc/*.conf* "$out"/etc
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
