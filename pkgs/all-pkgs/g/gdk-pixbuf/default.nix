{ stdenv
, lib
, makeWrapper

, gdk-pixbuf_unwrapped
, librsvg
, shared-mime-info
}:

# This is a meta package for all gdk-pixbuf loaders, see
# gdk-pixbuf_unwrapped for the actual gdk-pixbuf package.

stdenv.mkDerivation rec {
  name = "gdk-pixbuf_wrapped-${gdk-pixbuf_unwrapped.version}";

  setupHook = ./setup-hook.sh;

  unpackPhase = ":";

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    gdk-pixbuf_unwrapped
    librsvg
  ];

  loadersCache = gdk-pixbuf_unwrapped.loadersCache;

  configurePhase = ":";

  buildPhase = /* Generate combined loaders cache */ ''
    export GDK_PIXBUF_MODULE_FILE='loaders.cache'

    echo "Generating loaders.cache"
    gdk-pixbuf-query-loaders --update-cache \
      ${gdk-pixbuf_unwrapped}/${gdk-pixbuf_unwrapped.loadersCachePath}/loaders/*.so \
      ${librsvg}/${librsvg.loadersCachePath}/loaders/*.so
  '' + /* Generate combined thumbnailer */ ''
    install -D -m 644 -v \
      ${gdk-pixbuf_unwrapped}/share/thumbnailers/gdk-pixbuf-thumbnailer.thumbnailer \
      $out/share/thumbnailers/gdk-pixbuf-thumbnailer.thumbnailer

    librsvgmimetypes="$(
      cat ${librsvg}/share/thumbnailers/librsvg.thumbnailer |
        grep -oP '(?<=MimeType=).*'
    )"
    sed -i $out/share/thumbnailers/gdk-pixbuf-thumbnailer.thumbnailer \
      -e "/^MimeType=/ s,;$,;$librsvgmimetypes," \
      -e "s,${gdk-pixbuf_unwrapped},$out,"
  '';

  installPhase = ''
    install -vD -m 644 loaders.cache \
      $out/${gdk-pixbuf_unwrapped.loadersCache}

    mkdir -pv $out/bin
    ln -sv ${gdk-pixbuf_unwrapped}/bin/gdk-pixbuf-csource $out/bin/
    ln -sv ${gdk-pixbuf_unwrapped}/bin/gdk-pixbuf-pixdata $out/bin/
    ln -sv ${gdk-pixbuf_unwrapped}/bin/gdk-pixbuf-thumbnailer $out/bin/
  '';

  preFixup = ''
    wrapProgram $out/bin/gdk-pixbuf-csource \
      --set 'GDK_PIXBUF_MODULE_FILE' "$out/${loadersCache}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/gdk-pixbuf-pixdata \
      --set 'GDK_PIXBUF_MODULE_FILE' "$out/${loadersCache}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/gdk-pixbuf-thumbnailer \
      --set 'GDK_PIXBUF_MODULE_FILE' "$out/${loadersCache}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  dontStrip = true;

  passthru = {
    inherit (gdk-pixbuf_unwrapped)
      loadersCache
      loadersCachePath;
  };

  meta = with lib; {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
