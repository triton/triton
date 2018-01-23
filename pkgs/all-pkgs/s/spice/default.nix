{ stdenv
, fetchurl
, python3Packages

, celt_0-5
, cyrus-sasl
, glib
, gstreamer
, gst-plugins-base
, libcacard
, libjpeg
, lz4
, openssl
, orc
, spice-protocol
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "spice-0.14.0";

  src = fetchurl {
    url = "http://www.spice-space.org/download/releases/${name}.tar.bz2";
    multihash = "QmZ6j9JvFUUxHnaZmdkmdrwHmVjKkUXkf89Jwr77Qjobp9";
    hashOutput = false;
    sha256 = "3adb9495b51650e5eab53c74dd6a74919af4b339ff21721d9ab2a45b2e3bb848";
  };

  nativeBuildInputs = [
    python3Packages.python
  ];

  buildInputs = [
    celt_0-5
    cyrus-sasl
    glib
    gstreamer
    gst-plugins-base
    libcacard
    libjpeg
    lz4
    openssl
    orc
    spice-protocol
    xorg.pixman
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-smartcard"
    "--enable-gstreamer=1.0"
    "--enable-lz4"
    "--with-sasl"
  ];

  postInstall = ''
    ln -sv spice-server $out/include/spice
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
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
