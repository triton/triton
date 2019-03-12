{ stdenv
, fetchurl
, lib
#, meson
#, ninja

, libdrm
, libx11
, libxext
, libxfixes
, opengl-dummy
, wayland
}:

let
  driverDir = "${opengl-dummy.driverSearchPath}/lib/dri";

  version = "2.4.0";
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
    sha256 = "99263056c21593a26f2ece812aee6fe60142b49e6cd46cb33c8dddf18fc19391";
  };

  #nativeBuildInputs = [
  #  meson
  #  ninja
  #];

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
    "--enable-glx"
    "--enable-wayland"
    "--enable-va-messaging"
    "--with-drivers-path=${driverDir}"
  ];

  #mesonFlags = [
  #  "-Ddriverdir=${driverDir}"
  #  "-Dwith_x11=yes"
  #  "-Dwith_glx=yes"
  #  "-Dwith_wayland=yes"
  #];

  preInstall = ''
    installFlagsArray+=("LIBVA_DRIVERS_PATH=$out/lib/dri")
  '';

  passthru = {
    inherit driverDir;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha1Urls = map (n: "${n}.sha1sum") src.urls;
      };
      failEarly = true;
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
