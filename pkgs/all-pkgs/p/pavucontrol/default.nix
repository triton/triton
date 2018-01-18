{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, gdk-pixbuf
, gtkmm_3
, libcanberra
, pulseaudio_lib
, shared-mime-info
}:

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "pavucontrol-3.0";

  src = fetchurl {
    url = "https://freedesktop.org/software/pulseaudio/pavucontrol/${name}.tar.xz";
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
    gtkmm_3
    libcanberra
    pulseaudio_lib
  ];

  postPatch = /* Use an icon that is supported in adwaita */ ''
    sed -i src/pavucontrol.glade \
      -e 's/stock_lock/insert-link-symbolic/'
  '';

  configureFlags = [
    "--${boolEn (gtkmm_3 != null)}-gtk3"
    "--disable-lynx"
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram $out/bin/pavucontrol \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  meta = with stdenv.lib; {
    description = "PulseAudio Volume Control";
    homepage = https://freedesktop.org/software/pulseaudio/pavucontrol/ ;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
