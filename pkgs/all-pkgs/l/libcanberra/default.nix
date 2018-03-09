{ stdenv
, fetchTritonPatch
, fetchurl
, lib
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

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libcanberra-0.30";

  src = fetchurl {
    url = "http://0pointer.de/lennart/projects/libcanberra/${name}.tar.xz";
    multihash = "QmdHpboSUCqS17x13gf7fwnc6Ns3usHYyPZLwsXo2JQPUF";
    sha256 = "0wps39h8rx2b00vyvkia5j40fkak3dpipp1kzilqla0cgvk73dn2";
  };

  patches = [
    # gtk: Don't assume all GdkDisplays are GdkX11Displays: broadway/wayland
    # Fixed in >0.30
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
    libice
    libsm
    libvorbis
    libx11
    pulseaudio_lib
    systemd_lib
    tdb
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-systemdsystemunitdir=$out/lib/systemd/system")
  '';

  configureFlags = [
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-oss"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--${boolEn (systemd_lib != null)}-udev"
    "--${boolEn (
      gstreamer != null
      && gst-plugins-base != null)}-gstreamer"
    "--enable-null"
    "--disable-gtk"
    "--${boolEn (gtk3 != null)}-gtk3"
    "--${boolEn (tdb != null)}-tdb"
    "--disable-lynx"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  passthru = {
    gtkModule = "/lib/gtk-2.0/";
  };

  meta = with lib; {
    description = "XDG Sound Theme and Name Specifications";
    homepage = http://0pointer.de/lennart/projects/libcanberra/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
