{ stdenv
, fetchurl
, python2

, celt_0_5_1
, cyrus-sasl
, glib
, libcacard
, libjpeg
, lz4
, pixman
, openssl
, spice-protocol
, zlib
}:

stdenv.mkDerivation rec {
  name = "spice-0.12.7";

  src = fetchurl {
    url = "http://www.spice-space.org/download/releases/${name}.tar.bz2";
    allowHashOutput = false;
    sha256 = "1c8e96cb9e833e23372e2f461508135903b697fd8c6daff565e9e87f6d2f6aba";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    celt_0_5_1
    cyrus-sasl
    glib
    libcacard
    libjpeg
    lz4
    pixman
    openssl
    spice-protocol
    zlib
  ];

  configureFlags = [
    "--with-sasl"
    "--enable-client"
    "--enable-lz4"
  ];

  postInstall = ''
    ln -s spice-server $out/include/spice
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
      pgpKeyId = "29AC6C82";
      pgpKeyFingerprint = "94A9 F756 61F7 7A61 6864  9B23 A9D8 C214 29AC 6C82";
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    description = "Complete open source solution for interaction with virtualized desktop devices";
    homepage = http://www.spice-space.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
