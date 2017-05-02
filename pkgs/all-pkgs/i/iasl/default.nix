{ stdenv
, bison
, fetchurl
, flex
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "2017-03-03";
  version' = replaceChars ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "iasl-${version}";

  src = fetchurl {
    url = "https://acpica.org/sites/acpica/files/acpica-unix-${version'}.tar.gz";
    multihash = "QmVf7ZLx8dL4mJjzVcFpwuvke6NagRHJ1Tg1QsT3KgYn1T";
    sha256 = "c093c9eabd1f8c51d79364d829975c5335c8028c4816a7a80dfb8590f31889b5";
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
