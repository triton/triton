{ stdenv
, fetchurl

, gst-plugins-base
, bzip2
, libva
, libdrm
, udev
, xorg
, mesa
, yasm
, gstreamer
#, gst-plugins-bad
, nasm
, libvpx
}:

stdenv.mkDerivation rec {
  name = "gstreamer-vaapi-0.7.0";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/vaapi/releases/gstreamer-vaapi/"
        + "${name}.tar.bz2";
    sha256 = "14jal2g5mf8r59w8420ixl3kg50vcmy56446ncwd0xrizd6yms5b";
  };

  configureFlags = [
    "--disable-builtin-libvpx"
    "--with-gstreamer-api=1.0"
  ];

  configurePhase = ''
    ./configure --help
  '';

  nativeBuildInputs = [
    bzip2
  ];

  buildInputs = [
    gstreamer
    gst-plugins-base
    #gst-plugins-bad
    libva
    libdrm
    udev
    xorg.libX11
    xorg.libXext
    xorg.libXv
    xorg.libXrandr
    xorg.libSM
    xorg.libICE
    mesa
    nasm
    libvpx
  ];

  preConfigure = "
    export GST_PLUGIN_PATH_1_0=$out/lib/gstreamer-1.0
    mkdir -p $GST_PLUGIN_PATH_1_0
  ";

  meta = with stdenv.lib; {
    description = "";
    homepage = https://github.com/01org/gstreamer-vaapi;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
