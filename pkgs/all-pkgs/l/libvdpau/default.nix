{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, libx11
, libxext
, opengl-dummy
, xorgproto
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
    libx11
    libxext
    xorgproto
  ];

  patches = [
    (fetchTritonPatch {
      rev = "091e0ea204a9808a92583eec3e60e7a5eeb554a2";
      file = "l/libvdpau/libvdpau-1.1.1-mesa_dri2-Add-missing-include-of-config.h-to-define.patch";
      sha256 = "f9ee2809d65b3384fce2293d500169225f4ea613d673d277798d5d601f9d5eaf";
    })
  ];

  configureFlags = [
    "--enable-dri2"
    "--disable-documentation"
    "--with-module-dir=${opengl-dummy.driverSearchPath}/lib/vdpau"
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

  meta = with lib; {
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
