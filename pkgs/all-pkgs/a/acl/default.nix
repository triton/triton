{ stdenv
, fetchurl
, gettext

, attr
}:

let
  tarballUrls = version: [
    "mirror://savannah/acl/acl-${version}.src.tar.gz"
  ];

  version = "2.2.52";
in
stdenv.mkDerivation rec {
  name = "acl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "179074bb0580c06c4b4137be4c5a92a701583277967acdb5546043c7874e0d23";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    attr
  ];

  postPatch =
    /* Upstream use C++-style comments in C code. Remove them. This
       comment breaks compilation with strict gcc flags are used. */ ''
    sed -i include/acl.h \
      -e '/^\/\//d'
  '';

  configureFlags = [
    "--enable-gettext"
    "--disable-lib64"
    "AWK=gawk"
    "ECHO=exho"
    "MAKE=make"
    "MSGFMT=msgfmt"
    "MSGMERGE=msgmerge"
    "SED=sed"
    "XGETTEXT=xgettext"
    "ZIP=gzip"
  ];

  installTargets = [
    "install"
    "install-lib"
    "install-dev"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.2.52";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "600C D204 FBCE A418 BD2C  A74F 1543 4326 0542 DF34";
      inherit (src) outputHashAlgo;
      outputHash = "179074bb0580c06c4b4137be4c5a92a701583277967acdb5546043c7874e0d23";
    };
  };

  meta = with stdenv.lib; {
    description = "Library and tools for manipulating access control lists";
    homepage = http://savannah.nongnu.org/projects/acl;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
