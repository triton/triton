{ stdenv
, bison
, fetchurl
, flex
, lib
}:

let
  inherit (lib)
    replaceChars;

  version = "2018-02-09";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmV2H7gbpGckSdEP7PjNgrj4mC96CSrU8TTACGYVeGdMjP";
    sha256 = "c57f427fc83003472cc15e8ee727d2832d552793f8f9745bf7dbf24d1477ede6";
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
