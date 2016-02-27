{ stdenv
, fetchTritonPatch
, fetchurl
, libtool

, alsa-lib
, gdk-pixbuf
, glib
, gstreamer
, gst-plugins-base
, gtk3
, libcap
, libvorbis
, pulseaudio_lib
, systemd_lib
, tdb
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libcanberra-0.30";

  src = fetchurl {
    url = "http://0pointer.de/lennart/projects/libcanberra/${name}.tar.xz";
    sha256 = "0wps39h8rx2b00vyvkia5j40fkak3dpipp1kzilqla0cgvk73dn2";
  };

  patches = [
    # gtk: Don't assume all GdkDisplays are GdkX11Displays: broadway/wayland (from 'master')
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "libcanberra/libcanberra-0.30-wayland.patch";
      sha256 = "ab3a989e346f871b22c99bcb8b6203eb800bc83f66269f3c26133a1edf5fbd5d";
    })
  ];

  nativeBuildInputs = [
    libtool
  ];

  buildInputs = [
    alsa-lib
    gdk-pixbuf
    glib
    gstreamer
    gst-plugins-base
    gtk3
    libcap
    libvorbis
    pulseaudio_lib
    systemd_lib
    tdb
    xorg.libICE
    xorg.libSM
    xorg.libX11
  ];

  configureFlags = [
    (enFlag "alsa" (alsa-lib != null) null)
    "--disable-oss"
    (enFlag "pulse" (pulseaudio_lib != null) null)
    (enFlag "udev" (systemd_lib != null) null)
    (enFlag "gstreamer" (
      gstreamer != null
      && gst-plugins-base != null) null)
    "--enable-null"
    "--disable-gtk"
    (enFlag "gtk3" (gtk3 != null) null)
    (enFlag "tdb" (tdb != null) null)
    "--disable-lynx"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-systemdsystemunitdir=$(out)/lib/systemd/system"
  ];

  passthru = {
    gtkModule = "/lib/gtk-2.0/";
  };

  meta = with stdenv.lib; {
    description = "XDG Sound Theme and Name Specifications";
    homepage = http://0pointer.de/lennart/projects/libcanberra/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
