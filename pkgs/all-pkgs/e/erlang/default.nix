{ stdenv
, autoconf
, bison
, fetchFromGitHub
, flex
, lib
, libxml2
, libxslt
, perl

, ncurses
, opengl-dummy
, openssl
, unixODBC
, wxGTK
, zlib

, graphical ? false
}:

let
  version = "20.0";

  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "erlang-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "erlang";
    repo = "otp";
    rev = "OTP-${version}";
    sha256 = "6f171c1142829fe3a87d584b646668ed98828180162c2ba66bdc6975c2198812";
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
    opengl-dummy
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

  meta = with lib; {
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
