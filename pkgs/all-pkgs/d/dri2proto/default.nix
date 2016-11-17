{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "dri2proto-2.8";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "f9b55476def44fc7c459b2537d17dbc731e36ed5d416af7ca0b1e2e676f8aa04";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org DRI2 protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
