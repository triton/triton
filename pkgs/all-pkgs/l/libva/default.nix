{ stdenv
, fetchurl

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

stdenv.mkDerivation rec {
  name = "libva-1.8.0";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmQ3LheJKGMQRJCoNMGnyoTrCdVjoLrRj9ZDACaBzSWwoo";
    sha256 = "eb92f3dcbe3981df3575348377263b31361113c77b2c3745f23174d1f562d658";
  };

  buildInputs = [
    libdrm
    mesa
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
  ];

  configureFlags = [
    "--enable-drm"
    "--enable-x11"
    "--enable-glx"
    "--enable-egl"
    "--enable-wayland"
    "--enable-va-messaging"
    "--enable-dummy-driver"
    "--with-drivers-path=${mesa_noglu.driverSearchPath}/lib/dri"
  ];

  preInstall = ''
    installFlagsArray+=("LIBVA_DRIVERS_PATH=$out/lib/dri")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Url = map (n: "${n}.sha1sum") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Video Acceleration (VA) API for Linux";
    homepage = http://www.freedesktop.org/wiki/Software/vaapi;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
