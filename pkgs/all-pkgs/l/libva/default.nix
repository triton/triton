{ stdenv
, fetchurl
, lib

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "libva-${version}";

  src = fetchurl rec {
    urls = [
      ("https://github.com/01org/libva/releases/download/${version}/"
        + "${name}.tar.bz2")
      ("https://www.freedesktop.org/software/vaapi/releases/libva/"
        + "${name}.tar.bz2")
    ];
    hashOutput = false;
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
    "--disable-docs"
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

  meta = with lib; {
    description = "Libva is an implementation for VA-API (VIdeo Acceleration API)";
    homepage = https://github.com/01org/libva;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
