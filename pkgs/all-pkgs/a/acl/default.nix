{ stdenv
, fetchurl
, gettext

, attr
}:

let
  tarballUrls = version: [
    "mirror://savannah/acl/acl-${version}.tar.gz"
  ];

  version = "2.2.53";
in
stdenv.mkDerivation rec {
  name = "acl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "06be9865c6f418d851ff4494e12406568353b891ffe1f596b34693c387af26c7";
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
      urls = tarballUrls "2.2.53";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "600C D204 FBCE A418 BD2C  A74F 1543 4326 0542 DF34"
        # Mike Frysinger
        "B902 B527 1325 F892 AC25  1AD4 4163 3B9F E837 F581"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "06be9865c6f418d851ff4494e12406568353b891ffe1f596b34693c387af26c7";
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
