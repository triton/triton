{ stdenv
, fetchurl
, gettext

, libidn
, libpsl ? null
, openssl_1-0-2
, util-linux_lib

, perl
, perlPackages
, python3
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

stdenv.mkDerivation rec {
  name = "wget-1.19";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.xz";
    hashOutput = false;
    sha256 = "0f1157bbf4daae19f3e1ddb70c6ccb2067feb834a6aa23c9d9daa7f048606384";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    libidn
    libpsl
    openssl_1-0-2
    util-linux_lib
  ] ++ optionals doCheck [
    perl
    perlPackages.IOSocketSSL
    perlPackages.LWP
    python3
  ];

  postPatch = ''
    for i in "doc/texi2pod.pl" "util/rmold.pl" ; do
      sed -i "$i" \
        -e 's|/usr/bin.*perl|${perl}/bin/perl|g'
    done
  '' + optionalString doCheck ''
    # Work around lack of DNS resolution in chroots.
    for i in "tests/"*.pm "tests/"*.px ; do
      sed -i "$i" \
        -e 's/localhost/127.0.0.1/g'
    done
  '';

  configureFlags = [
    "--enable-opie"
    "--enable-digest"
    "--enable-ntlm"
    "--disable-debug"
    "--disable-valgrind-tests"
    "--disable-assert"
    "--enable-largefile"
    "--enable-threads=posix"
    "--enable-nls"
    "--enable-rpath"
    "--enable-ipv6"
    "--enable-iri"
    "--enable-pcre"
    "--with-ssl=openssl"
    "--with-zlib"
    "--with-metalink"
    "--with-openssl"
    "--with-libidn"
    "--with-libuuid"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
