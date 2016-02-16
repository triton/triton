{ lib, stdenv, fetchurl, openssl, kerberos, db, gettext, pam }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "cyrus-sasl-2.1.26${optionalString (kerberos == null) "-without-kerberos"}";

  src = fetchurl {
    url = "ftp://ftp.cyrusimap.org/cyrus-sasl/${name}.tar.gz";
    sha256 = "1hvvbcsg21nlncbgs0cgn3iwlnb3vannzwsp6rwvnn9ba4v53g4g";
  };

  buildInputs =
    [ openssl db gettext kerberos ]
    ++ lib.optional stdenv.isLinux pam;

  patches = [ ./missing-size_t.patch ]; # https://bugzilla.redhat.com/show_bug.cgi?id=906519

  configureFlags = [
    "--with-openssl=${openssl}"
    "--enable-auth-sasldb"
  ];

  # Set this variable at build-time to make sure $out can be evaluated.
  preConfigure = ''
    configureFlagsArray+=("--with-plugindir=$out/lib/sasl2")
    configureFlagsArray+=("--with-configdir=$out/lib/sasl2")
    configureFlagsArray+=("--with-saslauthd=/run/saslauthd")
  '';

  preBuild = ''
    cat sasldb/Makefile
  '';

  meta = {
    homepage = "http://cyrusimap.web.cmu.edu/";
    description = "library for adding authentication support to connection-based protocols";
    platforms = platforms.unix;
    maintainers = with maintainers; [ simons ];
  };
}
