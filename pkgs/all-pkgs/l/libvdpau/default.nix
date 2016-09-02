{ stdenv
, fetchurl

, xorg
, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "libvdpau-1.1.1";

  src = fetchurl {
    url = "https://people.freedesktop.org/~aplattner/vdpau/${name}.tar.bz2";
    multihash = "Qmant8W2qcuE8iyP8gAXPzkRxn9gFaKXgjKxNPqFbtQPPj";
    hashOutput = false;
    sha256 = "857a01932609225b9a3a5bf222b85e39b55c08787d0ad427dbd9ec033d58d736";
  };

  buildInputs = [
    xorg.dri2proto
    xorg.libX11
    xorg.libXext
  ];

  configureFlags = [
    "--enable-dri2"
    "--disable-documentation"
    "--with-module-dir=${mesa_noglu.driverSearchPath}/lib/vdpau"
  ];

  preInstall = ''
    installFlagsArray+=("moduledir=$out/lib/vdpau")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "BD68 A042 C603 DDAD 9AA3  54B0 F56A CC8F 09BA 9635";
    };
  };

  meta = with stdenv.lib; {
    description = "VDPAU wrapper and trace libraries";
    homepage = https://people.freedesktop.org/~aplattner/vdpau/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
