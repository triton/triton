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
  name = "less-487";

  src = fetchurl {
    url = "http://www.greenwoodsoftware.com/less/${name}.tar.gz";
    multihash = "QmNvvbq4XTRfX5ZiAnYi7DbnVviNeDwXiAcYnpqWemr8c9";
    sha256 = "f3dc8455cb0b2b66e0c6b816c00197a71bf6d1787078adeee0bcf2aea4b12706";
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
