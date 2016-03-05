{ stdenv, fetchurl, gettext, libidn, pkgconfig
, perl, perlPackages, python3
, libpsl ? null, openssl ? null }:

stdenv.mkDerivation rec {
  name = "wget-1.17.1";

  src = fetchurl {
    url = "mirror://gnu/wget/${name}.tar.xz";
    sha256 = "1jcpvl5sxb2ag8yahpy370c5jlfb097a21k2mhsidh4wxdhrnmgy";
  };

  preConfigure = ''
    for i in "doc/texi2pod.pl" "util/rmold.pl"; do
      sed -i "$i" -e 's|/usr/bin.*perl|${perl}/bin/perl|g'
    done
  '' + stdenv.lib.optionalString doCheck ''
    # Work around lack of DNS resolution in chroots.
    for i in "tests/"*.pm "tests/"*.px
    do
      sed -i "$i" -e's/localhost/127.0.0.1/g'
    done
  '';

  nativeBuildInputs = [ gettext pkgconfig ];
  buildInputs = [ libidn libpsl ]
    ++ stdenv.lib.optionals doCheck [ perl perlPackages.IOSocketSSL perlPackages.LWP python3 ]
    ++ stdenv.lib.optional (openssl != null) openssl;

  configureFlags =
    if openssl != null then "--with-ssl=openssl" else "--without-ssl";

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Tool for retrieving files using HTTP, HTTPS, and FTP";
    license = licenses.gpl3Plus;

    homepage = http://www.gnu.org/software/wget/;

    maintainers = with maintainers; [ fpletz ];
    platforms = platforms.all;
  };
}
