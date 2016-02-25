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
    sed -i '/^install:/ s,install-am,,g' Makefile
  '';

  # We only want a certain subset of libraries
  buildFlags = optionals static [
    "libelf.a"
  ] ++ optionals shared [
    "libelf.so"
  ];

  installTargets = [
    "install-includeHEADERS"
    "install-pkgincludeHEADERS"
  ] ++ optionals static [
    "install-libLIBRARIES"
  ] ++ optionals shared [
    "install"
  ];

  # Install the pkgconfig file
  postInstall = ''
    cd ../config
    make libelf.pc
    mkdir -p $out/lib/pkgconfig
    cp libelf.pc $out/lib/pkgconfig
  '';

  preFixup = ''
    ${if static then "" else "!"} test -e $out/lib/libelf.a
    ${if shared then "" else "!"} test -e $out/lib/libelf.so
  '';
})
