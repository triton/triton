{ stdenv
, fetchurl
, which
, perl

, gmp
, guile
, libxml2
}:

let
  version = "5.18.16";

  tarballUrls = version: [
    "mirror://gnu/autogen/rel${version}/autogen-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "autogen-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f8a13466b48faa3ba99fe17a069e71c9ab006d9b1cfabe699f8c60a47d5bb49a";
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
      -e 's,guile_versions_to_search=",\03.0 ,g' \
      -i configure

    grep -q '< 203000' agen5/guile-iface.h
    sed -i 's,< 203000,< 400000,g' agen5/guile-iface.h

    sed -i 's, -Werror,,' configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.18.16";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "44A0 88E2 95C3 A722 C450  590E C9EF 76DE B74E E762";
      inherit (src) outputHashAlgo;
      outputHash = "f8a13466b48faa3ba99fe17a069e71c9ab006d9b1cfabe699f8c60a47d5bb49a";
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
