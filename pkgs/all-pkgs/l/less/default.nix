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
  name = "less-533";

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") (fileUrls name);
    multihash = "QmSzsMJrjjMwBvwbvgUcfrWycy5xKcLt2KHEtQhGyTLtCK";
    hashOutput = false;
    sha256 = "fa6f951f770274cc0b3e7f751ce03e500b7ecf44b1c85817dd23deb7e184dbfb";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") (fileUrls name);
        pgpKeyFingerprint = "AE27 252B D684 6E7D 6EAE  1DD6 F153 A7C8 3323 5259";
      };
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
