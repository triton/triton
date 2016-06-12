{ stdenv
, autoconf
, automake
, fetchgit
, fetchurl
, gnome-common
, gtk-doc
, intltool
, itstool
, libtool
, makeWrapper

, adwaita-icon-theme
, atk
, dconf
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, libcanberra
, libnotify
, libxml2
, pango
, systemd_lib
}:

let
  inherit (stdenv.lib)
    enFlag
    replaceStrings;
in

stdenv.mkDerivation rec {
  name = "gnome-bluetooth-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  /*src = fetchurl {
    urls = "mirror://gnome/sources/gnome-bluetooth/${versionMajor}/${name}.tar.xz";
    sha256 = "e481b70423e52adc3c3aa919eeb033b47f9cd1598d6c0c7f384c0bd10f4e8ce3";
  };*/
  # # TODO: Use fetchurl again once upstream publishes a tarball
  src = fetchgit {
    url = "git://git.gnome.org/gnome-bluetooth";
    rev = "refs/tags/GNOMEBT_V_${replaceStrings ["."] ["_"] version}";
    sha256 = "1vji82jvcn1p14hgw21m9ma710m49zrbq432rj0l3lvjhbnxrfhn";
  };

  nativeBuildInputs = /* XXX: Disable for release tarballs */ [
    autoconf
    automake
    gnome-common
    gtk-doc
    libtool
  ] ++ [
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dconf
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    libcanberra
    libnotify
    libxml2
    pango
    systemd_lib
  ];

  postPatch =
    /* XXX: disable for release tarballs */ ''
      USE_GNOME2_MACROS=1 gnome-autogen.sh
    '' +
    /* XXX: enable for release tarballs
       Regenerate gdbus-codegen files to allow using any glib version
    	 https://bugzilla.gnome.org/show_bug.cgi?id=758096 */ ''
    	#rm -v lib/bluetooth-client-glue.{c,h}
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-desktop-update"
    "--disable-icon-update"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-documentation"
  ];

  postConfigure =
    /* https://bugzilla.gnome.org/show_bug.cgi?id=655517 */ ''
      sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
    '';

  preFixup = ''
    wrapProgram $out/bin/bluetooth-sendto \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "Bluetooth graphical utilities integrated with GNOME";
    homepage = https://wiki.gnome.org/Projects/GnomeBluetooth;
    license = with licenses; [
      #fdl11
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
