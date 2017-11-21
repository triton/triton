{ stdenv
, bison
, fetchurl
, flex
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "2017-11-10";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmdYk4mcdETNo9jVzJdjhEwrbkREWGC2bbyFySLsFojNAz";
    sha256 = "56ac1f870db698fc46f9be0698abe6f4b5bf189bfb12cf982302c0a8f920856a";
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
