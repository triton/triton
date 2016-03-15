{ stdenv
, fetchurl
, gettext
, intltool
, perl
, perlPackages

, gdk-pixbuf
, glib
, libimobiledevice
, libusb
, libxml2
, mutagen
, python
, pythonPackages
, sg3_utils
, sqlite
, systemd_lib
, taglib
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionalString
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "libgpod-0.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/gtkpod/${name}.tar.bz2";
    sha256 = "0pcmgv1ra0ymv73mlj4qxzgyir026z9jpl5s5bkg35afs1cpk2k3";
  };

  nativeBuildInputs = [
    gettext
    intltool
    libimobiledevice.swig
    perl
    perlPackages.XMLParser
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    libimobiledevice
    libusb
    libxml2
    mutagen
    pythonPackages.pygobject
    python
    sg3_utils
    sqlite
    systemd_lib
    taglib
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    (enFlag "udev" (systemd_lib != null) null)
    (enFlag "libxml" (libxml2 != null) null)
    (enFlag "gdk-pixbuf" (gdk-pixbuf != null) null)
    (enFlag "pygobject" (pythonPackages.pygobject != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-more-warnings"
    #(wtFlag "hal" (hal != null) null)
    (wtFlag "libimobiledevice" (libimobiledevice != null) null)
    (wtFlag "udev-dir" (systemd_lib != null) "\${out}/share/udev")
    (wtFlag "python" (python != null) null)
    "--without-mono"
  ];

  preFixup =
    /* libgpod installs libgpod-sharp.pc unconditionally */ ''
      rm -vf $out/lib/pkgconfig/libgpod-sharp.pc
    '';

  meta = with stdenv.lib; {
    description = "Library to access the contents of an iPod";
    homepage = http://www.gtkpod.org/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
