{ stdenv
, fetchurl
, gettext
}:

let
  tarballUrls = version: [
    "mirror://savannah/attr/attr-${version}.src.tar.gz"
  ];

  version = "2.4.47";
in
stdenv.mkDerivation rec {
  name = "attr-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "25772f653ac5b2e3ceeb89df50e4688891e21f723c460636548971652af0a859";
  };

  nativeBuildInputs = [
    gettext
  ];

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
  ];

  installTargets = [
    "install"
    "install-lib"
    "install-dev"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.4.47";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "600C D204 FBCE A418 BD2C  A74F 1543 4326 0542 DF34";
      inherit (src) outputHashAlgo;
      outputHash = "25772f653ac5b2e3ceeb89df50e4688891e21f723c460636548971652af0a859";
    };
  };

  meta = with stdenv.lib; {
    description = "Library and tools for manipulating extended attributes";
    homepage = http://savannah.nongnu.org/projects/attr/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
