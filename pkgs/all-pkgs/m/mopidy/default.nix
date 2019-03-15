{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, gobject-introspection
, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
, gst-plugins-ugly
, gst-python
, gstreamer
, pygobject
, pykka
, requests
, tornado
}:

let
  inherit (lib)
    makeSearchPath;

  version = "2.2.2";
in

buildPythonPackage rec {
  name = "mopidy-${version}";

  src = fetchPyPi {
    package = "Mopidy";
    inherit version;
    sha256 = "b41f5ab1e83c5e5f74fdb792c8fd5ba63b7fd227d04df266dba5189bc552a93d";
  };

  buildInputs = [
    gobject-introspection
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
  ];

  propagatedBuildInputs = [
    gst-python
    pygobject
    pykka
    requests
    tornado
  ];

  GST_PLUGIN_PATH = makeSearchPath "lib/gstreamer-1.0" [
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
  ];

  preFixup = ''
    wrapProgram $out/bin/mopidy \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix GST_PLUGIN_PATH : "$GST_PLUGIN_PATH"
  '';

  disabled = isPy3;
  doCheck = false;

  meta = with lib; {
    description = "Music server with MPD and Spotify support";
    homepage = http://www.mopidy.com/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
