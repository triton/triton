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

let
  rev = "7a912d90e2f2eccbc1ded619b21c681d7adec048";
  date = "2017-12-30";
in
stdenv.mkDerivation rec {
  name = "cyrus-sasl-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "cyrusimap";
    repo = "cyrus-sasl";
    inherit rev;
    sha256 = "bca8d4d1093839300736fbead70eab9dd85388cca09a52d6f64935a3a05d8596";
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

  installParallel = false;

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
