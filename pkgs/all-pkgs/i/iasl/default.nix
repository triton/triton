{ stdenv
, bison
, fetchurl
, flex
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "2016-11-17";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmXZz1PhLhfNtsvQv45ucD8cX2pdzig2CShFNwJQnEJD4F";
    sha256 = "703e352a2d3f57905d0b5fc8ce11a1f5312bf5d601808a18c120ae7828f45031";
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
