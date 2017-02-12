{ stdenv
, bison
, fetchurl
, flex

, libdaemon
}:

stdenv.mkDerivation rec {
  name = "radvd-2.16";
  
  src = fetchurl {
    url = "http://www.litech.org/radvd/dist/${name}.tar.xz";
    multihash = "QmSAn9d1Sy3NJUWJwEaJ6Kb9q37BZn7ZYepywWZAZyPpcU";
    hashOutput = false;
    sha256 = "317ce738d40a421c290feb47b3a88c4fc7b2f8ce152c2012591cac36ecc36ae8";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    libdaemon
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      sha512Url = map (n: "${n}.sha512") src.urls;
      sha256Url = map (n: "${n}.sha256") src.urls;
      sha1Url = map (n: "${n}.sha1") src.urls;
      pgpKeyFingerprint = "B11F 2EED 32FB 6728 F700  337C 411F A8C1 12D9 1A31";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.litech.org/radvd/;
    description = "IPv6 Router Advertisement Daemon";
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
