{ stdenv
, autoconf
, bison
, fetchFromGitHub
, flex
, libxml2
, libxslt
, perl

, mesa
, ncurses
, openssl
, unixODBC
, wxGTK
, zlib

, graphical ? false
}:

let
  version = "19.1.2";

  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "erlang-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "erlang";
    repo = "otp";
    rev = "OTP-${version}";
    sha256 = "6e5ed5e595dc238facbfd01a7a8fdaed3a1c2e8b506e5eef629d1b8a821f0dba";
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
  ] ++ optionals graphical [
    mesa
    wxGTK
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
