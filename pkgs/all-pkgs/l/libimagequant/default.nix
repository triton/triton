{ stdenv
, lib
, fetchFromGitHub
}:

let
  version = "2.12.6";
in
stdenv.mkDerivation rec {
  name = "libimagequant-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ImageOptim";
    repo = "libimagequant";
    rev = version;
    sha256 = "cb39e3554edf387e1fc4c0c9af937fa8f6d1b98cf52c24a160d9351425f42f90";
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
