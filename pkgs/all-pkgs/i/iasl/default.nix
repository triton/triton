{ stdenv
, bison
, fetchurl
, flex
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "2017-09-29";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmTzmPjjVeWdeMLMxEf3ubzAbBqhHaC4mZXP5r7K7kxEin";
    sha256 = "c786868ae6c7a4c7bca19a5ca66bfb16740cad5c1c01b21642932f2f0dea9cc8";
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

  meta = with stdenv.lib; {
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
