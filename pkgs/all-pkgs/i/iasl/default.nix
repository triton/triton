{ stdenv
, bison
, fetchurl
, flex
, lib
}:

let
  inherit (lib)
    replaceChars;

  version = "2018-03-13";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmSFmgRjB22BCHR9jZ5qShmaYXUkNARJ2Pr3P51GMXCgAr";
    sha256 = "958b5b75617732f6024484c32476cf0759b5777eb827a5e45f1cf3b45d174b15";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  NIX_CFLAGS_COMPILE = "-O3";

  buildFlags = [
    "iasl"
  ];

  installPhase = ''
    install -d $out/bin
    install generate/unix/bin*/iasl $out/bin
  '';

  meta = with lib; {
    description = "Intel ACPI Compiler";
    homepage = http://www.acpica.org/;
    license = licenses.iasl;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
