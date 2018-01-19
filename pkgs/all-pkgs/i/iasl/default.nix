{ stdenv
, bison
, fetchurl
, flex
, lib
}:

let
  inherit (lib)
    replaceChars;

  version = "2018-01-05";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmfUsRmpEeySggPuuYUcq8NRJmBG7E2CjTDdrYpFz9NVbm";
    sha256 = "414f843ac6c7c53bbd2a830b092a2a27c49172b0878fd27fe306dd526b78b921";
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
