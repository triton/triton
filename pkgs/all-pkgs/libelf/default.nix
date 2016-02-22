{ stdenv
, elfutils

, static ? false
, shared ? true
}:

assert static || shared;

let
  inherit (stdenv.lib) optionals optionalString;
in
elfutils.overrideDerivation (attrs: {
  name = "libelf-${attrs.version}";

  # We only want to build libelf
  preBuild = ''
    cd libelf
  '';

  # We only want a certain subset of libraries
  buildFlags = optionals static [
    "libelf.a"
    "libelf_pic.a"
  ] ++ optionals shared [
    "libelf.so"
  ];

  installPhase = ''
    # Install the library components
    mkdir -p $out/{include,lib/pkgconfig}
    cp libelf.h elf.h $out/include
  '' + optionalString static ''
    cp libelf.a libelf_pic.a $out/lib
  '' + optionalString shared ''
    cp libelf.so $out/lib
  '' + ''
    # Install the pkgconfig file
    cd ../config
    make libelf.pc
    cp libelf.pc $out/lib/pkgconfig
  '';
})
