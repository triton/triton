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
  version = "19.1";

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
    sha256 = "e1c0568870b21db231c2260aeedfcbe356e0e9493abc6ae6baa70a960ce47fbb";
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
