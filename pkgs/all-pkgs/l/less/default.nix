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

  fileUrls = name: [
    "http://www.greenwoodsoftware.com/less/${name}"
  ];
in
stdenv.mkDerivation rec {
  name = "less-530";

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") (fileUrls name);
    multihash = "QmUXLRe6hL1spWcAK7Kq5RsM3eyiDZEE61EFAPQ2Mo9X36";
    hashOutput = false;
    sha256 = "503f91ab0af4846f34f0444ab71c4b286123f0044a4964f1ae781486c617f2e2";
  };

  buildInputs = [
    ncurses
    pcre
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-secure"
    "--with-regex=${boolString (pcre != null) "pcre" "posix"}"
  ];

  preConfigure = /* Unicode */ ''
    export ac_cv_lib_ncursesw_initscr=unicode
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") (fileUrls name);
      pgpKeyFingerprint = "AE27 252B D684 6E7D 6EAE  1DD6 F153 A7C8 3323 5259";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
