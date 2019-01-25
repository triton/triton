{ stdenv
, fetchurl
, lib
, perl
, which
}:

stdenv.mkDerivation rec {
  name = "valgrind-3.14.0";

  src = fetchurl {
    url = "http://www.valgrind.org/downloads/${name}.tar.bz2";
    multihash = "QmX6SRssywahzQFYNiQaTxz8D32o6M5WpXJqHNrgDVZMU1";
    hashOutput = false;
    sha256 = "037c11bfefd477cc6e9ebe8f193bb237fe397f7ce791b4a4ce3fa1c6a520baa5";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-lto"
    "--enable-tls"
  ];

  # We don't need any of the static libraries
  postInstall = ''
    find "$out"/lib -name '*'.a -delete
    rm -r "$out"/lib/pkgconfig
  '';

  stackProtector = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Confirm = "74175426afa280184b62591b58c671b3";
      };
    };
  };
  
  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
