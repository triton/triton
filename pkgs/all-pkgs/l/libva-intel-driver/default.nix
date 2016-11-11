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
  name = "libva-intel-driver-1.7.3";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/${name}.tar.bz2";
    sha1Url = "${url}.sha1sum";
    multihash = "QmUVKEkCug69AxiLGjAnuzBKo8WmmWGbnFQwgXBAp86RNg";
    sha256 = "76ad37d9fd5ae23d8ce6052d50b5e6438a8df9e769b13fe34b771cd453f4f937";
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
