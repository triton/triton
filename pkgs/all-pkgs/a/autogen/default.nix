{ stdenv
, fetchurl
, which
, perl

, gmp
, guile
, libxml2
}:

let
  version = "5.18.10";

  tarballUrls = version: [
    "mirror://gnu/autogen/rel${version}/autogen-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "autogen-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "4e248e02c50404ea5c5fc29027d26600f895a9eae7ea5ef851be2c8587abc148";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    guile
    libxml2
    gmp
  ];

  # Fix a broken sed expression used for detecting the minor
  # version of guile we are using
  postPatch = ''
    sed -i "s,sed '.*-I.*',sed 's/\\\(^\\\| \\\)-I/\\\1/g',g" configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.18.10";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "44A0 88E2 95C3 A722 C450  590E C9EF 76DE B74E E762";
      inherit (src) outputHashAlgo;
      outputHash = "4e248e02c50404ea5c5fc29027d26600f895a9eae7ea5ef851be2c8587abc148";
    };
  };

  meta = with stdenv.lib; {
    description = "Automated text and program generation tool";
    homepage = http://www.gnu.org/software/autogen/;
    license = with licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
