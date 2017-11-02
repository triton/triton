{ stdenv
, fetchurl
, lib

, libdrm
, libx11
, libxext
, libxfixes
, opengl-dummy
, wayland

, channel ? "2"
}:

let
  inherit (lib)
    boolEn
    optionals;

  sources = {
    "1" = {
      version = "1.8.3";
      sha256 = "56ee129deba99b06eb4a8d4f746b117c5d1dc2ec5b7a0bfc06971fca1598ab9b";
    };
    "2" = {
      version = "2.0.0";
      sha256 = "bb0601f9a209e60d8d0b867067323661a7816ff429021441b775452b8589e533";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libva-${source.version}";

  src = fetchurl rec {
    urls = [
      ("https://github.com/01org/libva/releases/download/${source.version}/"
        + "${name}.tar.bz2")
      ("https://www.freedesktop.org/software/vaapi/releases/libva/"
        + "${name}.tar.bz2")
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    libdrm
    libx11
    libxext
    libxfixes
    opengl-dummy
    wayland
  ];

  configureFlags = [
    "--disable-docs"
    "--enable-drm"
    "--enable-x11"
    "--${boolEn opengl-dummy.glx}-glx"
    "--enable-wayland"
    "--enable-va-messaging"
    "--with-drivers-path=${opengl-dummy.driverSearchPath}/lib/dri"
  ] ++ optionals (channel == "1") [
    "--${boolEn opengl-dummy.egl}-egl"
    "--enable-dummy-driver"
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
