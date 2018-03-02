{ stdenv
, fetchurl
, intltool
, lib
, makeWrapper

, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk_2
, gtk_3
, libx11
, libxfce4ui
, libxfce4util
, perlPackages
, shared-mime-info
, xorgproto
}:

let
  channel = "0.12";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "exo-${version}";

  src = fetchurl {
    url = "https://archive.xfce.org/src/xfce/exo/${channel}/${name}.tar.bz2";
    multihash = "QmYFgqvrWQTFbBGukxhNJoZSpD6CDnxr767wVENjyn3vfj";
    sha256 = "64b88271a37d0ec7dca062c7bc61ca323116f7855092ac39698c421a2f30a18f";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    glib
    gnome-themes-standard
    gtk_2
    gtk_3
    libx11
    libxfce4ui
    libxfce4util
    perlPackages.URI
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-gio-unix"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-debug"
    #"--disable-linker-opts"
    #"--disable-visibility"
    "--with-x"
  ];

  preFixup = ''
    wrapProgram $out/bin/exo-desktop-item-edit \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
    wrapProgram $out/bin/exo-preferred-applications \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  meta = with lib; {
    description = "Extensions to Xfce by os-cillation";
    homepage = http://www.xfce.org/;
    license = with licenses; [
      gpl2
      lgpl2
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
