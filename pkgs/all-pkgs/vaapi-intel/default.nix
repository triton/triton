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
  name = "libva-intel-driver-1.7.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/${name}.tar.bz2";
    sha1Confirm = "6766ff2e8134e09e9204ec9ccd3b8d550890d5d2";
    sha256 = "9d19d6c789a9a4fbce23c4f0eaf993ba776b512bec4c87982ab17ac841435c0c";
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
