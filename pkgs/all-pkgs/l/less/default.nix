{ stdenv
, fetchurl
, lib

, ncurses
, pcre
}:

let
  inherit (lib)
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "less-481";

  src = fetchurl {
    url = "http://www.greenwoodsoftware.com/less/${name}.tar.gz";
    multihash = "QmVy7jpqHzt9Buwirm9b6ZRUHgQT3Xv1ePEXn25adXeHbb";
    sha256 = "3fa38f2cf5e9e040bb44fffaa6c76a84506e379e47f5a04686ab78102090dda5";
  };

  buildInputs = [
    ncurses
    pcre
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--enable-largefile"
    "--with-secure"
    "--without-no-float"
    "--with-regex=${boolString (pcre != null) "pcre" "posix"}"
  ];

  preConfigure = ''
    chmod +x ./configure
  '' + /* Unicode */ ''
    export ac_cv_lib_ncursesw_initscr=unicode
  '';

  meta = with stdenv.lib; {
    description = "A more advanced file pager than ‘more’";
    homepage = http://www.greenwoodsoftware.com/less/;
    license = with licenses; [
      bsd2
      gpl3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
