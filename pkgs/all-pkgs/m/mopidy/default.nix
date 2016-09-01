{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k

, gobject-introspection
, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
, gst-plugins-ugly
, gst-python
, gstreamer
, pygobject3
, pykka
, requests
, tornado
}:

let
  inherit (stdenv.lib)
    makeSearchPath;

  version = "2.0.1";
in

buildPythonPackage rec {
  name = "mopidy-${version}";

  src = fetchPyPi {
    package = "Mopidy";
    inherit version;
    sha256 = "af3129d8b7e45c8a2af34f2b50592f64c00aaa0400ef6e6c742b6587ea9bdf67";
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
    pygobject3
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

  disabled = isPy3k;
  doCheck = false;

  meta = with stdenv.lib; {
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
