{ stdenv
, fetchurl
, gettext
, intltool

, gtkmm3
, libcanberra
, libpulseaudio
, gnome3
}:

stdenv.mkDerivation rec {
  name = "pavucontrol-3.0";

  src = fetchurl {
    url = "http://freedesktop.org/software/pulseaudio/pavucontrol/${name}.tar.xz";
    sha256 = "14486c6lmmirkhscbfygz114f6yzf97h35n3h3pdr27w4mdfmlmk";
  };

  configureFlags = [
    "--enable-gtk3"
    "--disable-lynx"
    "--enable-nls"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c++11"
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    gtkmm3
    libcanberra
    libpulseaudio
    gnome3.defaultIconTheme
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "PulseAudio Volume Control";
    homepage = http://freedesktop.org/software/pulseaudio/pavucontrol/ ;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
