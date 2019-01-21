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
  rev = "36fa6b9351d8467e04e12ffd058894ec5ecbded9";
  date = "2018-11-25";
in
stdenv.mkDerivation rec {
  name = "cyrus-sasl-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cyrusimap";
    repo = "cyrus-sasl";
    inherit rev;
    sha256 = "83327e9e4a678cf8b7a2d598b144044300280092b34ac284177bce21740188d5";
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
