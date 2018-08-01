{ stdenv
, fetchFromGitHub
, lib

, nasm
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    elem
    optionals
    optionalString
    platforms;

  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "openh264-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cisco";
    repo = "openh264";
    rev = "v${version}";
    sha256 = "16f07de5e382c67d6f672b4a4a1837fdc97d4517dd3905693d8d4d9b166753c1";
  };

  nativeBuildInputs = [
    nasm
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = optionals (elem targetSystem platforms.bit64) [
    "ENABLE64BIT=Yes"
  ];

  meta = with lib; {
    description = "A library for encoding & decoding h.264/AVC";
    homepage = http://www.openh264.org;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
