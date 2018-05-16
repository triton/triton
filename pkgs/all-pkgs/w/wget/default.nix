{ stdenv
, fetchurl
, gettext
, lib

, c-ares
, libidn2
, libpsl
, libunistring
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
  name = "wget-1.19.5";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.lz";
    hashOutput = false;
    sha256 = "29fbe6f3d5408430c572a63fe32bd43d5860f32691173dfd84edc06869edca75";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    c-ares
    libidn2
    libpsl
    libunistring
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

  # The configure.ac is bad and doesn't set the rpath
  # even though it uses libidn2
  NIX_LDFLAGS = "-rpath ${libidn2}/lib";

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
    "--with-cares"
    "--with-openssl"
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
