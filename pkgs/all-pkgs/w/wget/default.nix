{ stdenv
, fetchurl
, gettext
, lib

, c-ares
, libidn2
#, libpsl
, lzip
, openssl
, pcre
, util-linux_lib
, zlib

, perl
, perlPackages
, python3
}:

let
  inherit (lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "wget-1.19.4";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.lz";
    hashOutput = false;
    sha256 = "2fc0ffb965a8dc8f1e4a89cbe834c0ae7b9c22f559ebafc84c7874ad1866559a";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    c-ares
    libidn2
    #libpsl  # FIXME: libpsl propagates libunistring causing libidn2 to be linked twice
    lzip
    openssl
    pcre
    util-linux_lib
    zlib
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
    "--enable-xattr"
    "--without-libpsl"  # FIXME
    "--with-ssl=openssl"
    "--with-zlib"
    "--with-metalink"
    "--with-cares"
    "--with-openssl"
    "--with-libidn"
    "--with-libuuid"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "7845 120B 07CB D8D6 ECE5  FF2B 2A17 43ED A91A 35B6";
      inherit (src) urls outputHash outputHashAlgo;
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
