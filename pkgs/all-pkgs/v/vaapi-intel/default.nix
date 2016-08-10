{ stdenv
, fetchurl
, gnum4
, python

, libdrm
, libva
, mesa_noglu
, wayland
, xorg
}:

stdenv.mkDerivation rec {
  name = "libva-intel-driver-1.7.1";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/${name}.tar.bz2";
    sha1Url = "${url}.sha1sum";
    sha256 = "1ed7717a4058030d381a07c1afe53781ccdcc8643edbc02e769f5b72a316dcb5";
  };

  nativeBuildInputs = [
    gnum4
    python
  ];

  buildInputs = [
    libdrm
    libva
    mesa_noglu
    wayland
    xorg.intelgputools
    xorg.libX11
    xorg.xproto
  ];

  patchPhase = ''
    patchShebangs ./src/shaders/gpp.py
  '';

  preConfigure = ''
    sed -i -e "s,LIBVA_DRIVERS_PATH=.*,LIBVA_DRIVERS_PATH=$out/lib/dri," configure
  '';

  configureFlags = [
    "--enable-drm"
    "--enable-x11"
    "--enable-wayland"
  ];

  meta = with stdenv.lib; {
    homepage = http://cgit.freedesktop.org/vaapi/intel-driver/;
    description = "Intel driver for the VAAPI library";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
