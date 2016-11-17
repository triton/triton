{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xcmiscproto-1.2.2";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "b13236869372256c36db79ae39d54214172677fb79e9cdc555dceec80bd9d2df";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
  ];

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
