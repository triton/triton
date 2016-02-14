{ stdenv
, fetchurl

, glibmm
, gst-plugins-base_0
, gstreamer_0
, libsigcxx
, libxmlxx
}:

stdenv.mkDerivation rec {
  name = "gstreamermm-${version}";
  versionMajor = "0.10";
  versionMinor = "11";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url    = "mirror://gnome/sources/gstreamermm/${versionMajor}/" +
             "${name}.tar.xz";
    sha256 = "1ipbhbbcym33dqhw701nank3r0dim385qbwznyfad51m6rvz7d8j";
  };

  buildInputs = [
    glibmm
    gst-plugins-base_0
    gstreamer_0
    libsigcxx
    libxmlxx
  ];

  doCheck = false;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ bindings for the GStreamer streaming multimedia library";
    homepage = http://www.gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };

}
