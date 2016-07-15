{ stdenv
, fetchurl
, gettext

, libidn
, libpsl ? null
, openssl
, util-linux_lib

, perlPackages
, python3
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

stdenv.mkDerivation rec {
  name = "wget-1.18";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.xz";
    sha256 = "b5b55b75726c04c06fe253daec9329a6f1a3c0c1878e3ea76ebfebc139ea9cc1";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    libidn
    libpsl
    openssl
    util-linux_lib
  ] ++ optionals doCheck [
    perlPackages.perl
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
