{ stdenv
, fetchurl
, lib
, util-macros

, libice
, util-linux_lib
, xorgproto
, xtrans
}:

let
  inherit (lib)
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libSM-1.2.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "0baca8c9f5d934450a70896c4ad38d06475521255ca63b717a6510fdb6e287bd";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libice
    util-linux_lib
    xorgproto
    xtrans
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--${boolWt (util-linux_lib != null)}-libuuid"
  ];

  meta = with lib; {
    description = "X.Org Session Management library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
