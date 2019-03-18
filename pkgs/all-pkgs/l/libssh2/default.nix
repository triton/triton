{ stdenv
, fetchurl

, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libssh2-1.8.1";

  src = fetchurl {
    url = "https://www.libssh2.org/download/${name}.tar.gz";
    multihash = "QmScmpHweA1xmEa1rv3UtekFXVMGjcW8MCBi6dvDmtuTbi";
    hashOutput = false;
    sha256 = "40b517f35b1bb869d0075b15125c7a015557f53a5a3a6a8bffb89b69fd70f159";
  };

  buildInputs = [
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-examples-build"
    "--with-openssl"
    "--with-libz"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = http://www.libssh2.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
