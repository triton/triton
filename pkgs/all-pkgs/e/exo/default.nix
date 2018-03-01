{ stdenv
, fetchurl
, intltool
, lib
, makeWrapper

, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk_2
, libx11
, libxfce4ui
, libxfce4util
, perlPackages
, shared-mime-info
, xproto
}:

let
  inherit (lib)
    boolEn;

  channel = "0.12";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "exo-${version}";

  src = fetchurl {
    url = "http://archive.xfce.org/src/xfce/exo/${channel}/${name}.tar.bz2";
    multihash = "QmTiBHtvFbXZq4Cb33gW5x3i4ia547sSYRu8YVrmR55Rgf";
    sha256 = "c4994f9bcb0e0c3e2f7c647d9715ed22ea5c9b091320916e15ca7255ebf39822";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    glib
    gnome-themes-standard
    gtk_2
    libx11
    libxfce4ui
    libxfce4util
    perlPackages.URI
    xproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (glib != null)}-gio-unix"
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
