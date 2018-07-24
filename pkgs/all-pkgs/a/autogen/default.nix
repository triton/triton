{ stdenv
, fetchurl
, which
, perl

, gmp
, guile
, libxml2
}:

let
  version = "5.18.14";

  tarballUrls = version: [
    "mirror://gnu/autogen/rel${version}/autogen-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "autogen-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ffc7ab99382116852fd4c73040c124799707b2d9b00a60b54e8b457daa7a06e4";
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

  configureFlags = [
    "--enable-snprintfv-install"
  ];

  # Fix a broken sed expression used for detecting the minor
  # version of guile we are using
  postPatch = ''
    sed \
      -e "s,sed '.*-I.*',sed 's/\\\(^\\\| \\\)-I/\\\1/g',g" \
      -e 's,guile_versions_to_search=",\02.2 ,g' \
      -i configure

    grep -q '< 201000' agen5/guile-iface.h
    sed -i 's,< 201000,< 203000,g' agen5/guile-iface.h

    sed -i 's, -Werror,,' configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.18.14";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "44A0 88E2 95C3 A722 C450  590E C9EF 76DE B74E E762";
      inherit (src) outputHashAlgo;
      outputHash = "ffc7ab99382116852fd4c73040c124799707b2d9b00a60b54e8b457daa7a06e4";
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
