{ stdenv, fetchurl, yacc, flex, xorg }:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.5.0";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    sha1 = "z9dvxrkcyb4b7f2zybgkrqb9zcxrj9vi";
  };

  nativeBuildInputs = [ yacc flex ];
  buildInputs = [ xorg.xkeyboardconfig xorg.libxcb ];

  configureFlags = ''
    --with-xkb-config-root=${xorg.xkeyboardconfig}/etc/X11/xkb
  '';

  meta = {
    description = "A library to handle keyboard descriptions";
    homepage = http://xkbcommon.org;
  };
}

