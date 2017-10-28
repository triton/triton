{ stdenv
, fetchurl
, gettext
, intltool
, perl
, perlPackages

, gdk-pixbuf
, glib
, libimobiledevice
, libplist
, libusb
, libxml2
, mutagen
, pythonPackages
, sg3-utils
, sqlite
, systemd_lib
, taglib
, zlib
}:

let
  inherit (stdenv.lib)
    boolEn
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libgpod-0.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/gtkpod/${name}.tar.bz2";
    multihash = "QmQHafZSqYSAdTqbNqjFLdo9zhcAP4URDbUhdHftjg6WVX";
    sha256 = "638a7959d04e95f1e62abad02bd33702e4e8dfef98485ac7d9d50395c37e955d";
  };

  nativeBuildInputs = [
    gettext
    intltool
    perl
    perlPackages.XMLParser
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    libimobiledevice
    libplist
    libusb
    libxml2
    mutagen
    pythonPackages.pygobject_2
    pythonPackages.python
    sg3-utils
    sqlite
    systemd_lib
    taglib
    zlib
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-udev-dir=$out/share/udev")
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (systemd_lib != null)}-udev"
    "--${boolEn (libxml2 != null)}-libxml"
    "--${boolEn (gdk-pixbuf != null)}-gdk-pixbuf"
    "--${boolEn (pythonPackages.pygobject != null)}-pygobject"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-more-warnings"
    "--without-hal"
    "--${boolWt (libimobiledevice != null)}-libimobiledevice"
    "--${boolWt (pythonPackages.python != null)}-python"
    "--without-mono"
  ];

  postInstall =
    /* libgpod installs libgpod-sharp.pc unconditionally */ ''
      rm -vf $out/lib/pkgconfig/libgpod-sharp.pc
    '';

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
      pgpKeyFingerprint = "A525 E3EA 186A AB45 DD0F  86AF 24A4 69FB 7A56 F78E";
    };
  };

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
