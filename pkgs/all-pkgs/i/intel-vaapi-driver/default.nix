{ stdenv
, fetchurl
, gnum4
, lib
, python

#, intelgputools
, libdrm
, libva
, libx11
, libxext
, libxfixes
, opengl-dummy
, wayland
, xorg
, xorgproto
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "intel-vaapi-driver-${version}";

  src = fetchurl rec {
    urls = [
      ("https://github.com/01org/intel-vaapi-driver/releases/download/"
        + "${version}/${name}.tar.bz2")
      ("https://www.freedesktop.org/software/vaapi/releases/"
        + "libva-intel-driver/${name}.tar.bz2")
    ];
    hashOutput = false;
    sha256 = "ecfaf2ccc4b9af7340e002d2ef807d1e33051d4992f1983f5f4d60e516f86bdf";
  };

  nativeBuildInputs = [
    gnum4
    xorg.intelgputools
    python
  ];

  buildInputs = [
    libdrm
    libva
    libx11
    libxext
    libxfixes
    opengl-dummy
    wayland
    xorgproto
  ];

  patchPhase = ''
    patchShebangs ./src/shaders/gpp.py
  '';

  preConfigure = ''
    sed -i configure \
      -e "s,LIBVA_DRIVERS_PATH=.*,LIBVA_DRIVERS_PATH=$out/lib/dri,"
  '';

  configureFlags = [
    "--enable-drm"
    "--enable-x11"
    "--enable-wayland"
    "--enable-hybrid-codec"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Url = map (n: "${n}.sha1sum") src.urls;
    };
    failEarly = true;
  };

  meta = with lib; {
    description = "VA-API user mode driver for Intel GEN Graphics family";
    homepage = https://github.com/01org/intel-vaapi-driver;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
