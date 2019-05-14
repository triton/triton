{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, lib

, c-ares
, gpgme
, libidn2
, libmetalink
, libpsl
, libunistring
, lzip
, openssl
, pcre2_lib
, util-linux_lib
, zlib
}:

let
  inherit (lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "wget-1.20.3";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.lz";
    hashOutput = false;
    sha256 = "69607ce8216c2d1126b7a872db594b3f21e511e660e07ca1f81be96650932abb";
  };

  nativeBuildInputs = [
    gettext
    lzip
  ];

  buildInputs = [
    c-ares
    gpgme
    libidn2
    libmetalink
    libpsl
    libunistring
    openssl
    pcre2_lib
    util-linux_lib
    zlib
  ];

  configureFlags = [
    "--with-ssl=openssl"
    "--with-metalink"
    "--with-cares"
    "--with-openssl"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      };
    };
  };

  meta = with lib; {
    description = "Tool for retrieving files using HTTP, HTTPS, and FTP";
    homepage = http://www.gnu.org/software/wget/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
