{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, googletest
, openssl
, xorg
}:

let
  version = "1.8.5";
in
stdenv.mkDerivation {
  name = "synergy-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "symless";
    repo = "synergy";
    rev = "v${version}-stable";
    sha256 = "03d7c046138c57e2c1c404a3209c86307aa88d3d9fed3824d86f50e2311a8cf3";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    googletest
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
    xorg.libXtst
    xorg.xproto
    xorg.xextproto
  ];

  postPatch = ''
    # Don't run or build tests
    sed -i '/add_subdirectory(test)/d' src/CMakeLists.txt
  '';

  installPhase = ''
    mkdir -p "$out"
    cd ../synergy-*

    mv bin "$out"

    mkdir -p "$out"/share/man/man1
    mv doc/synergyc.man "$out"/share/man/man1/synergyc.1
    mv doc/synergys.man "$out"/share/man/man1/synergys.1

    mkdir -p "$out"/etc
    cp doc/*.conf* "$out"/etc
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
