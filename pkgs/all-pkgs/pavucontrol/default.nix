{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, gdk-pixbuf
, gtkmm3
, libcanberra
, libpulseaudio
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "pavucontrol-3.0";

  src = fetchurl {
    url = "http://freedesktop.org/software/pulseaudio/pavucontrol/${name}.tar.xz";
    sha256 = "14486c6lmmirkhscbfygz114f6yzf97h35n3h3pdr27w4mdfmlmk";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    gtkmm3
    libcanberra
    libpulseaudio
  ];

  configureFlags = [
    (enFlag "gtk3" (gtkmm3 != null) null)
    "--disable-lynx"
    "--enable-nls"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c++11"
  ];

  preFixup = ''
    wrapProgram $out/bin/pavucontrol \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

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
