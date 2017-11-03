{ stdenv
, lib
, makeWrapper

, adwaita-icon-theme
, bubblewrap
, dconf
, evince
, gdk-pixbuf
, glib
, gnome-terminal
, gsettings-desktop-schemas
, gtk_3
, gvfs
, nautilus_unwrapped
, shared-mime-info
, totem
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
    gdk-pixbuf
    glib
    gnome-terminal
    gsettings-desktop-schemas
    gtk_3
    evince
    nautilus_unwrapped
    totem
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

  preFixup = ''
    wrapProgram $out/bin/nautilus \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --set 'NAUTILUS_EXTENSION_DIR' \
          "$out/lib/nautilus-${nautilus_unwrapped.version}/extensions-3.0/" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'PATH' : "${bubblewrap}/bin" \
      --prefix 'PATH' : "${evince}/bin" \
      --prefix 'PATH' : "${gdk-pixbuf}/bin" \
      --prefix 'PATH' : "${gnome-terminal}/bin" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'PATH' : "${totem}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "${nautilus_unwrapped}/share" \
      --prefix 'XDG_DATA_DIRS' : "${evince}/share" \
      --prefix 'XDG_DATA_DIRS' : "${gdk-pixbuf}/share" \
      --prefix 'XDG_DATA_DIRS' : "${gnome-terminal}/share" \
      --prefix 'XDG_DATA_DIRS' : "${totem}/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
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
