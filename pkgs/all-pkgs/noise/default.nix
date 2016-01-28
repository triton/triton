{ stdenv
, cmake
, fetchurl
, gettext

, glib
, gobject-introspection
, granite
, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
, gst-plugins-ugly
, gstreamer
, gtk3
, json-glib
#, libdbusmenu
, libgee
, libgpod
#, libindicate
, libnotify
, libpeas
, librsvg
, libsoup
, libxml2
, sqlheavy
, taglib
, vala
, zeitgeist

, atk
, cairo
, pango
}:

with {
  inherit (stdenv.lib)
    makeSearchPath;
};

stdenv.mkDerivation rec {
  name = "noise-${version}";
  versionMajor = "0.3";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://launchpad.net/noise/${versionMajor}.x/${version}/" +
          "+download/${name}.tgz";
    sha256 = "07hfdrjbqq683f3lp0yiysx7vmvszsghh97dafdyajwls1clcp14";
  };

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DICON_UPDATE=OFF"
    "-DGSETTINGS_COMPILE=ON"
    "-DVALA_EXECUTABLE=${vala}/bin/valac"
  ];

  nativeBuildInputs = [
    cmake
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    granite
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gstreamer
    gtk3
    json-glib
    #libdbusmenu
    libgee
    libgpod
    #libindicate
    libnotify
    libpeas
    librsvg
    libsoup
    libxml2
    sqlheavy
    taglib
    vala
    zeitgeist
  ];

  preFixup = ''
    gnomeWrapperArgs+=(
      "--prefix GST_PLUGIN_PATH : ${
        makeSearchPath "lib/gstreamer-1.0" [
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
          gstreamer
        ]}"
    )
  '';

  meta = with stdenv.lib; {
    description = "Music player for Elementary OS";
    homepage = https://launchpad.net/noise;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
