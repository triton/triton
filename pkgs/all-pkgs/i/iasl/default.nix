{ stdenv
, bison
, fetchurl
, flex
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "2017-01-19";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmRP8SEy1XrMWfmUkUxjZnHLTDGcp5vAvUxMNRo3zAADbr";
    sha256 = "766e39c96649f32f5288a033b818ffe85b9a80daaa9d6d80acb1e44dce233dc9";
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
