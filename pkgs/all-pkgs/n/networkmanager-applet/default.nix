{ stdenv
, fetchFromGitHub  # FIXME: remove this next release
, fetchurl
, intltool
, lib
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, atk
, dbus-glib
, dconf
, gconf
, gcr
, gdk-pixbuf
, glib
, glib-networking
, gnome-keyring
, gobject-introspection
, gsettings-desktop-schemas
, gtk_3
, hicolor-icon-theme
, iso-codes
, jansson
#, libglade
, libgnome-keyring
, libgudev
, libnotify
, libsecret
, libselinux
, mobile_broadband_provider_info
, modemmanager
, networkmanager
, pango
, polkit
, shared-mime-info
, systemd_lib

, channel
}:

let
  inherit (lib)
    boolTf;

  sources = {
    "1.8" = {
      version = "1.8.10";
      sha256 = "0adc4bfae8b49f7a1d929c22ef20933bd41fb4a8b458280f44c65f9e45b4c9c3";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "network-manager-applet-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/network-manager-applet/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  propagatedUserEnvPkgs = [
    gconf
    gnome-keyring
    hicolor-icon-theme
  ];

  nativeBuildInputs = [
    intltool
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus-glib
    dconf
    gdk-pixbuf
    gconf
    gcr
    glib
    libgnome-keyring
    gobject-introspection
    gsettings-desktop-schemas
    gtk_3
    hicolor-icon-theme
    iso-codes
    jansson
    #libglade
    libgudev
    libnotify
    libsecret
    libselinux
    modemmanager
    networkmanager
    pango
    polkit
    systemd_lib
  ];

  postPatch = /* handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/meson_post_install.py/d' \
      -e '/[^(]\snma_datadir,/d' \
      -e "s,[^(]\snma_sysconfdir,'$(type -P true)',"
  '' +  /* mobile_broadband_provider_info and network-manager-applet do not
           share the same prefix. */ ''
    grep -q 'MOBILE_BROADBAND_PROVIDER_INFO DATADIR"' src/libnm-gtk/nm-mobile-providers.c
    grep -q 'MOBILE_BROADBAND_PROVIDER_INFO DATADIR"' src/libnma/nma-mobile-providers.c
    sed -i src/libnm-gtk/nm-mobile-providers.c \
     -i src/libnma/nma-mobile-providers.c \
     -e 's,MOBILE_BROADBAND_PROVIDER_INFO DATADIR",MOBILE_BROADBAND_PROVIDER_INFO "${mobile_broadband_provider_info}/share,g'
  '';

  mesonFlags = [
    #"-Dlibnm_gtk=${boolTf }"
    #"-Dappindicator=${boolTf }"
    "-Dwwan=${boolTf (modemmanager != null)}"
    "-Dselinux=${boolTf (libselinux != null)}"
    "-Dteam=${boolTf (jansson != null)}"
    "-Dgcr=${boolTf (gcr != null)}"
    "-Dmore_asserts=no"
    "-Diso_codes=${boolTf (iso-codes != null)}"
    #"-Dld_gc=${boolTf }"
    "-Dgtk_doc=false"
    "-Dintrospection=${boolTf (gobject-introspection != null)}"
  ];

  postInstall = ''
    # Private libs are never actually installed.
    sed -i $out/lib/pkgconfig/libnma.pc \
      -i $out/lib/pkgconfig/libnm-gtk.pc \
      -e '/Libs.private/d'
  '';

  preFixup = ''
    wrapProgram "$out/bin/nm-applet" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "${gtk_3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share" \
      --prefix XDG_DATA_DIRS : "$out/share"

    wrapProgram "$out/bin/nm-connection-editor" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "${gtk_3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/network-manager-applet/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "NetworkManager control applet";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
