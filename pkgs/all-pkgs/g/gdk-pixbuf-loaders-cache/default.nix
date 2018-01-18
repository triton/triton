{ stdenv
, lib

, gdk-pixbuf
, libopenraw
, librsvg
}:

# This is a meta package for all gdk-pixbuf loaders to generate a single cache.

# NOTE: To add new loaders, append to propagatedBuildInputs.

let
  inherit (lib)
    makeSearchPath;
in
stdenv.mkDerivation rec {
  name = "gdk-pixbuf-loaders-cache-${gdk-pixbuf.version}";

  unpackPhase = ":";

  propagatedBuildInputs = [
    gdk-pixbuf
    libopenraw
    librsvg
  ];

  loadersSearchPath =
    makeSearchPath gdk-pixbuf.loadersCachePath propagatedBuildInputs;

  inherit (gdk-pixbuf) loadersCacheFile;

  configurePhase = ":";

  buildPhase = /* Generate combined loaders cache */ ''
    export GDK_PIXBUF_MODULE_FILE='loaders.cache'

    local -a loaderDirs=() loaderObjects=() loaderObjectsTmp
    local loaderDir loaderObject
    mapfile -t -d: loaderDirs < <(printf '%s' "$loadersSearchPath/loaders")
    for loaderDir in "''${loaderDirs[@]}"; do
      mapfile -t loaderObjectsTmp < <(find "$loaderDir" -name '*.so' -printf '%P\n')
      for loaderObject in "''${loaderObjectsTmp[@]}"; do
        loaderObjects+=("$loaderDir/$loaderObject")
      done
    done

    echo "Generating combined gdk-pixbuf loaders.cache" >&2
    echo "gdk-pixbuf-query-loaders --update-cache ''${loaderObjects[@]}" >&2
    gdk-pixbuf-query-loaders --update-cache "''${loaderObjects[@]}"
  '';

  installPhase = ''
    install -vD -m 644 loaders.cache $out/${gdk-pixbuf.loadersCacheFile}
  '';

  dontStrip = true;

  passthru = {
    cache = "${gdk-pixbuf.loaders}/${gdk-pixbuf.loadersCacheFile}";
  };

  meta = with lib; {
    description = "Combined gdk-pixbuf loaders cache";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
