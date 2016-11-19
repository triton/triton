{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "fontsproto-2.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "259046b0dd9130825c4a4c479ba3591d6d0f17a33f54e294b56478729a6e5ab8";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
  ];

  meta = with lib; {
    description = "X.Org Fonts protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
