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
  rev = "f76eb971d456619d0f26eb0c5c96157bee3d94e3";
  date = "2017-09-02";
in
stdenv.mkDerivation rec {
  name = "cyrus-sasl-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "cyrusimap";
    repo = "cyrus-sasl";
    inherit rev;
    sha256 = "75a0f7fa8b859c73cb6532f458d32bf7120f01b39907867ffd0beda2b4055979";
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

  #buildParallel = false;
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
