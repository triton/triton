{ stdenv
, fetchurl
, gettext
, intltool
, perl
, perlXMLParser

, gdk-pixbuf
, glib
, libimobiledevice
, libusb
, libxml2
, mutagen
, python
, pygobject
, sg3_utils
, sqlite
, taglib
, udev
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
    perlXMLParser
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    libimobiledevice
    libusb
    libxml2
    mutagen
    pygobject
    python
    sg3_utils
    sqlite
    taglib
    udev
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    (enFlag "udev" (udev != null) null)
    (enFlag "libxml" (libxml2 != null) null)
    (enFlag "gdk-pixbuf" (gdk-pixbuf != null) null)
    (enFlag "pygobject" (pygobject != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-more-warnings"
    #(wtFlag "hal" (hal != null) null)
    (wtFlag "libimobiledevice" (libimobiledevice != null) null)
    (wtFlag "udev-dir" (udev != null) "\${out}/lib/udev")
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
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
