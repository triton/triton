{ stdenv
, bison
, fetchurl
, flex
, libxml2
, libxslt
, perl

, ncurses
, openssl
, unixODBC
, zlib
}:

stdenv.mkDerivation rec {
  name = "erlang-${version}";
  version = "18.3";

  src = fetchurl {
    url = "http://erlang.org/download/otp_src_${version}.tar.gz";
    sha256 = "1hy9slq9gjvwdb504dmvp6rax90isnky6chqkyq5v4ybl4lq3azx";
  };

  nativeBuildInputs = [
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
