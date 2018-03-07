{ stdenv
, fetchurl
, gettext
, intltool
, lib
, makeWrapper
, perl

, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk_2
, gtk_3
, libice
, libsm
, libx11
, libxfce4util
, shared-mime-info
, xfconf
, xorgproto

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "4.12" = {
      version = "4.12.1";
      multihash = "QmRw2T45nvzKnRGsqNFpajLTKD64pUaxyy3sG9wD15SeYe";
      sha256 = "3d619811bfbe7478bb984c16543d980cadd08586365a7bc25e59e3ca6384ff43";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libxfce4ui-${source.version}";

  src = fetchurl {
    url = "http://archive.xfce.org/src/xfce/libxfce4ui/${channel}/"
      + "${name}.tar.bz2";
    hashOutput = false;
    inherit (source) multihash sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
    perl
  ];

  buildInputs = [
    glib
    gnome-themes-standard
    gtk_2
    gtk_3
    libice
    libsm
    libx11
    libxfce4util
    xfconf
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (gtk_3 != null)}-gtk3"
    "--enable-startup-notification"
    "--enable-keyboard-library"
    "--enable-gladeui"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-debug"
    #"--disable-linker-opts"
    #"--disable-visibility"
    "--with-x"
  ];

  preFixup = ''
    wrapProgram $out/bin/xfce4-about \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  meta = with lib; {
    description = "Unified widgets and session management libraries";
    homepage = http://www.xfce.org/projects/libxfce4;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
