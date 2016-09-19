{ stdenv
, autoconf
, bison
, fetchFromGitHub
, flex
, libxml2
, libxslt
, perl

, ncurses
, openssl
, unixODBC
, zlib
}:

let
  version = "19.0.7";
in
stdenv.mkDerivation rec {
  name = "erlang-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "erlang";
    repo = "otp";
    rev = "OTP-${version}";
    sha256 = "b113de739d52f56c6dcc7e45a03f2d502e451fa381e5f51247aabcad6a30b521";
  };

  nativeBuildInputs = [
    autoconf
    bison
    flex
    libxml2
    libxslt
    perl
  ];

  buildInputs = [
    ncurses
    openssl
    unixODBC
    zlib
  ];

  postPatch = ''
    find . -name configure -exec sed -i "s,/bin/rm,$(type -P rm),g" {} \;

    # Fix otb builder
    sed -i "s,/bin/pwd,$(type -P pwd),g" otp_build
    export HOME=$PWD/../
  '';

  preConfigure = ''
    ./otp_build autoconf
  '';

  configureFlags = [
    "--with-odbc=${unixODBC}"
    "--with-ssl=${openssl}"
    "--enable-hipe"
  ];

  meta = with stdenv.lib; {
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
