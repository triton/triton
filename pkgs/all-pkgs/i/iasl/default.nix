{ stdenv
, bison
, fetchurl
, flex
, lib
}:

let
  inherit (lib)
    replaceChars;

  version = "2018-06-29";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmYVtbFWVmZxFXTM3ZgQy7xH6fKtUDPx8ht6KJ7uyLYY63";
    sha256 = "70d11f3f2adbdc64a5b33753e1889918af811ec8050722fbee0fdfc3bfd29a4f";
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
