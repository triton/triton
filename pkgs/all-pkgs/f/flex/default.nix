{ stdenv
, bison
, fetchurl
, gnum4

, bootstrap ? false
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "2.6.4";
in
stdenv.mkDerivation rec {
  name = "${if bootstrap then "bootstrap-" else ""}flex-${version}";

  src = fetchurl {
    url = "https://github.com/westes/flex/releases/download/v${version}/flex-${version}.tar.gz";
    hashOutput = false;
    sha256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995";
  };

  nativeBuildInputs = [
    bison
    gnum4
  ];

  # Using static libraries fixes issues with references to
  # yylex in flex 2.6.0
  # This can be tested by building glusterfs
  configureFlags = [
    "--disable-shared"
  ];

  preFixup = optionalString bootstrap ''
    find "$out" -not -name bin -and -not -name share -mindepth 1 -maxdepth 1 | xargs -r rm -r
  '';

  ccFixFlags = !bootstrap;
  buildDirCheck = !bootstrap;
  disableStatic = false;

  meta = with stdenv.lib; {
    description = "A fast lexical analyser generator";
    homepage = http://flex.sourceforge.net/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
