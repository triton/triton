{ stdenv
, fetchurl
, lib

, libdrm
, libx11
, libxext
, libxfixes
, opengl-dummy
, wayland
}:

let
  inherit (lib)
    boolEn;

  version = "2.2.0";
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
    sha256 = "6f6ca04c785544d30d315ef130a6aeb9435b75f934d7fbe0e4e9ba6084ce4ef2";
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
    "--enable-x11"
    "--${boolEn opengl-dummy.glx}-glx"
    "--enable-wayland"
    "--enable-va-messaging"
    "--with-drivers-path=${opengl-dummy.driverSearchPath}/lib/dri"
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
