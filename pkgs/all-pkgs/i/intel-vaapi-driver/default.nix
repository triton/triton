{ stdenv
, fetchurl
, gnum4
, lib
, python

#, intelgputools
, libdrm
, libva
, libx11
, opengl-dummy
, wayland
, xorg
, xproto
}:

let
  version = "1.8.3";
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
    sha256 = "54411d9e579300ed63f8b9b06152a1a9ec95b7699507d7ffa014cd7b2aeaff6f";
  };

  nativeBuildInputs = [
    gnum4
    python
  ];

  buildInputs = [
    xorg.intelgputools
    libdrm
    libva
    libx11
    opengl-dummy
    wayland
    xproto
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
    "--disable-tests"
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
