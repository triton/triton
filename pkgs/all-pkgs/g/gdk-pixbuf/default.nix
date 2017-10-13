{ stdenv
, lib

, gdk-pixbuf_unwrapped
, librsvg
}:

# This is a meta package for all gdk-pixbuf loaders, see
# gdk-pixbuf_unwrapped for the actual gdk-pixbuf package.

stdenv.mkDerivation rec {
  name = "gdk-pixbuf_wrapped-${gdk-pixbuf_unwrapped.version}";

  setupHook = ./setup-hook.sh;

  unpackPhase = ":";

  propagatedBuildInputs = [
    gdk-pixbuf_unwrapped
    librsvg
  ];

  loadersCache = gdk-pixbuf_unwrapped.loadersCache;

  configurePhase = ":";

  buildPhase = ''
    export GDK_PIXBUF_MODULE_FILE='loaders.cache'

    echo "Generating loaders.cache"
    gdk-pixbuf-query-loaders --update-cache \
      ${gdk-pixbuf_unwrapped}/${gdk-pixbuf_unwrapped.loadersCachePath}/loaders/*.so \
      ${librsvg}/${librsvg.loadersCachePath}/loaders/*.so
  '';

  installPhase = ''
    install -vD -m 644 loaders.cache \
      $out/${gdk-pixbuf_unwrapped.loadersCache}
  '';

  dontStrip = true;

  passthru = {
    loadersCachePath = gdk-pixbuf_unwrapped.loadersCachePath;
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
