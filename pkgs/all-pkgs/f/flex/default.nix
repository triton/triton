{ stdenv
, bison
, fetchurl
, m4
}:

let
  version = "2.6.4";
in
stdenv.mkDerivation rec {
  name = "flex-${version}";

  src = fetchurl {
    url = "https://github.com/westes/flex/releases/download/v${version}/${name}.tar.gz";
    sha256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995";
  };

  nativeBuildInputs = [
    bison
    m4
  ];

  # Using static libraries fixes issues with references to
  # yylex in flex 2.6.0
  # This can be tested by building glusterfs
  configureFlags = [
    "--disable-shared"
  ];

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
