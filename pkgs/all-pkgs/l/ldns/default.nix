{ stdenv
, fetchurl
, perl

, openssl
}:

stdenv.mkDerivation rec {
  name = "ldns-1.7.1";

  src = fetchurl {
    url = "https://www.nlnetlabs.nl/downloads/ldns/${name}.tar.gz";
    multihash = "Qme9g4FYeQ7J7A3BfmBp6t1spoauKCV1TgJrQSTRGAVxXJ";
    hashOutput = false;
    sha256 = "8ac84c16bdca60e710eea75782356f3ac3b55680d40e1530d7cea474ac208229";
  };

  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-gost"
    "--enable-ed25519"
    "--enable-ed448"
    "--with-drill"
    "--with-ssl=${openssl}"
    "--with-ca-file=/etc/ssl/certs/ca-certificates.crt"
  ];

  postInstall = ''
    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/*-config "$dev"/bin

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        sha1Urls = map (n: "${n}.sha1") src.urls;
        sha256Urls = map (n: "${n}.sha256") src.urls;
        pgpKeyFingerprint = "DC34 EE5D B241 7BCC 151E  5100 E5F8 F821 2F77 A498";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Library with the aim of simplifying DNS programming in C";
    license = licenses.bsd3;
    homepage = "http://www.nlnetlabs.nl/projects/ldns/";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
