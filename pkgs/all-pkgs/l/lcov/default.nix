{ stdenv
, fetchurl
, lib
, perl
}:

let
  version = "1.14";
in
stdenv.mkDerivation rec {
  name = "lcov-${version}";

  src = fetchurl {
    url = "https://github.com/linux-test-project/lcov/releases/download/v${version}/${name}.tar.gz";
    sha256 = "14995699187440e0ae4da57fe3a64adc0a3c5cf14feab971f8db38fb7d8f071a";
  };

  nativeBuildInputs = [
    perl
  ];

  postPatch = ''
    patchShebangs bin
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
