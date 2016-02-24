{ stdenv
, autoreconfHook
, fetchurl
, python

, openssl
}:

stdenv.mkDerivation rec {
  name = "libevent-${version}";
  version = "2.0.22";

  src = fetchurl {
    url = "mirror://sourceforge/levent/libevent-${version}-stable.tar.gz";
    sha256 = "18qz9qfwrkakmazdlwxvjmw8p76g70n3faikwvdwznns1agw9hki";
  };

  nativeBuildInputs = [
    autoreconfHook
    python
  ];
  buildInputs = [
    openssl
  ];

  patchPhase = ''
    patchShebangs event_rpcgen.py
  '';

  meta = with stdenv.lib; {
    description = "Event notification library";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
