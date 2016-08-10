{ stdenv
, buildPythonPackage
, fetchPyPi

, pkgs
, pythonPackages
}:

let
  inherit (stdenv.lib)
    makeSearchPath;
  inherit (pythonPackages)
    isPy3k;
in

buildPythonPackage rec {
  name = "mopidy-${version}";
  version = "2.0.0";

  src = fetchPyPi {
    package = "Mopidy";
    inherit version;
    sha256 = "14a04c249f83d42f2012b580f3a05853f56320f1bb68ac91c4068b64c81a9265";
  };

  buildInputs = [
    pkgs.gobject-introspection
    pkgs.gst-plugins-base
    pkgs.gst-plugins-good
    pkgs.gst-plugins-ugly
    pkgs.gstreamer
  ];

  propagatedBuildInputs = [
    pythonPackages.gst-python
    pythonPackages.pygobject3
    pythonPackages.pykka
    pythonPackages.requests2
    pythonPackages.tornado
  ];

  GST_PLUGIN_PATH = makeSearchPath "lib/gstreamer-1.0" [
    pkgs.gst-plugins-base
    pkgs.gst-plugins-good
    pkgs.gst-plugins-ugly
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
