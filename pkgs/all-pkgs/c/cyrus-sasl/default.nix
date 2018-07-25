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
  rev = "e41cfb986c1b1935770de554872247453fdbb079";
  date = "2018-05-10";
in
stdenv.mkDerivation rec {
  name = "cyrus-sasl-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cyrusimap";
    repo = "cyrus-sasl";
    inherit rev;
    sha256 = "76a496ea30b52297fcf8ad11397d2e0f5cbec88e15c8f4d4098d8c0696357ab0";
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
