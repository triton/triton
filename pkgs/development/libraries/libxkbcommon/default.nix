{ stdenv, fetchurl, yacc, flex, xkeyboard_config, xorg }:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.5.0";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    sha1 = "z9dvxrkcyb4b7f2zybgkrqb9zcxrj9vi";
  };

  nativeBuildInputs = [ yacc flex ];
  buildInputs = [ xkeyboard_config xorg.libxcb ];

  configureFlags = ''
    --with-xkb-config-root=${xkeyboard_config}/etc/X11/xkb
  '';

  preBuild = stdenv.lib.optionalString stdenv.isDarwin ''
    sed -i 's/,--version-script=.*$//' Makefile
  '';

  meta = {
    description = "A library to handle keyboard descriptions";
    homepage = http://xkbcommon.org;
  };
}

