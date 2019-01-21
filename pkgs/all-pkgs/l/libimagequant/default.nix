{ stdenv
, lib
, fetchFromGitHub
}:

let
  version = "2.12.2";
in
stdenv.mkDerivation rec {
  name = "libimagequant-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ImageOptim";
    repo = "libimagequant";
    rev = version;
    sha256 = "e33e32d65831f747e2213a2be700374d334d8d552320e5f6f26d67b4acd24130";
  };

  postPatch = ''
    patchShebangs configure
  '';

  buildFlags = [
    "shared"
  ];

  installPhase = ''
    mkdir -p "$out"/{include,lib}
    cp libimagequant.so.* "$out"/lib
    ln -sv libimagequant.so.* "$out"/lib/libimagequant.so
    cp libimagequant.h "$out"/include
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
