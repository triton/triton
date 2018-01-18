{ stdenv
, lib
, makeWrapper

, adwaita-icon-theme
, bubblewrap
, dconf
, evince
, file-roller
, gdk-pixbuf
, glib
, gnome-terminal
, gobject-introspection
, gsettings-desktop-schemas
, gtk_3
, gvfs
, nautilus_unwrapped
, shared-mime-info
, totem
, tracker
}:

# NOTE: This wrapper is for working around circular dependencies.

stdenv.mkDerivation rec {
  name = "nautilus-wrapped-${nautilus_unwrapped.version}";

  unpackPhase = ":";

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    evince
    file-roller
    gdk-pixbuf
    glib
    gnome-terminal
    gobject-introspection
    gsettings-desktop-schemas
    gtk_3
    gvfs
    nautilus_unwrapped
    totem
    tracker
  ];

  installPhase = ''
    mkdir -pv $out/{bin,lib}/
    ln -sv ${nautilus_unwrapped}/bin/nautilus $out/bin/
    ln -sv ${nautilus_unwrapped}/bin/nautilus-autorun-software $out/bin/
    ln -sv ${nautilus_unwrapped}/bin/nautilus-desktop $out/bin/
    ln -sv ${nautilus_unwrapped}/lib/lib*.so* $out/lib/
    ln -sv ${nautilus_unwrapped}/share/ $out/
  '' + /**/ ''
    mkdir -pv $out/lib/nautilus-${nautilus_unwrapped.version}/extensions-3.0/
    for nautilusextension in "''${NAUTILUS_EXTENSION_DIRS[@]}"; do
      ln -sv $nautilusextension/* \
        $out/lib/nautilus-${nautilus_unwrapped.version}/extensions-3.0/
    done
  '';

  # FIXME: make NAUTILUS_EXTENSION_DIR overrideable
  preFixup = ''
    wrapProgram $out/bin/nautilus \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --set 'NAUTILUS_EXTENSION_DIR' \
          "$out/lib/nautilus-${nautilus_unwrapped.version}/extensions-3.0/" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'PATH' : "${bubblewrap}/bin" \
      --prefix 'PATH' : "${glib}/bin" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${evince}/share" \
      --prefix 'XDG_DATA_DIRS' : "${file-roller}/share" \
      --prefix 'XDG_DATA_DIRS' : "${gdk-pixbuf}/share" \
      --prefix 'XDG_DATA_DIRS' : "${gnome-terminal}/share" \
      --prefix 'XDG_DATA_DIRS' : "${gvfs}/share" \
      --prefix 'XDG_DATA_DIRS' : "${librsvg}/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "${totem}/share" \
      --prefix 'XDG_DATA_DIRS' : "${tracker}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"

    wrapProgram $out/bin/nautilus-desktop \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
