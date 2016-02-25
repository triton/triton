{ stdenv
, fetchurl
, gettext

, db
, kerberos
, openssl
, pam
}:

stdenv.mkDerivation rec {
  name = "cyrus-sasl-2.1.26";

  src = fetchurl {
    url = "ftp://ftp.cyrusimap.org/cyrus-sasl/${name}.tar.gz";
    sha256 = "1hvvbcsg21nlncbgs0cgn3iwlnb3vannzwsp6rwvnn9ba4v53g4g";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    db
    kerberos
    openssl
    pam
  ];

  # https://bugzilla.redhat.com/show_bug.cgi?id=906519
  patches = [
    ./missing-size_t.patch
  ];

  # Set this variable at build-time to make sure $out can be evaluated.
  preConfigure = ''
    configureFlagsArray+=("--with-plugindir=$out/lib/sasl2")
    configureFlagsArray+=("--with-configdir=$out/lib/sasl2")
    configureFlagsArray+=("--with-saslauthd=/run/saslauthd")
  '';

  configureFlags = [
    "--with-openssl=${openssl}"
    "--enable-auth-sasldb"
  ];

  meta = with stdenv.lib; {
    homepage = "http://cyrusimap.web.cmu.edu/";
    description = "library for adding authentication support to connection-based protocols";
    maintainers = with maintainers; [
      simons
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
