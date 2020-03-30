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
  name = "less-557";

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") (fileUrls name);
    multihash = "QmfCzU93Au5BqZyyb221FzuJVdKdAyAKy4SLFrMLikvXxW";
    hashOutput = false;
    sha256 = "510e1fe87de3579f7deb4bec38e6d0ad959663d54598729c4cc43a4d64d5b1f7";
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
