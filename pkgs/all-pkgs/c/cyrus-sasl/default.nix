{ stdenv
, autoreconfHook
, fetchFromGitHub
, gettext
, groff

, db
, kerberos
, openssl
, pam
}:

stdenv.mkDerivation rec {
  name = "cyrus-sasl-2016-12-15";

  src = fetchFromGitHub {
    version = 2;
    owner = "cyrusimap";
    repo = "cyrus-sasl";
    rev = "497c716c5f5f2ad6a1d189615b21b8d2741c3f71";
    sha256 = "94352571ba34268dea1cc80aa003ea076ba0a0c06617c99eb7e8af58396da552";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    groff
  ];

  buildInputs = [
    db
    kerberos
    openssl
    pam
  ];

  postPatch = ''
    # Use plugindir for sasldir
    sed -i plugins/Makefile.am \
      -e '/^sasldir =/s:=.*:= $(plugindir):'
  '';

  preConfigure = ''
    # Set this variable at build-time to make sure $out can be evaluated.
    configureFlagsArray+=(
      "--with-plugindir=$out/lib/sasl2"
      "--with-configdir=$out/lib/sasl2"
    )
  '';

  configureFlags = [
    "--with-openssl=${openssl}"
    "--with-saslauthd=/run/saslauthd"
  ];

  #parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "Library for authentication to connection-based protocols";
    homepage = "http://cyrusimap.web.cmu.edu/";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
