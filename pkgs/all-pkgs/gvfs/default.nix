{ stdenv
, docbook_xsl
, fetchurl
, intltool
, libtool
, libxslt
, makeWrapper

, avahi
, dbus
, fuse
, gconf
, gcr
, glib
, gnome-online-accounts
, gtk3
# TODO: add hal support
, hal ? null
, libarchive
, libbluray
, libcdio
, libgcrypt
, libgdata
, libgnome-keyring
, libgphoto2
, libgudev
, libmtp
, libsecret
, libsoup
, libxml2
, openssh
, samba
, systemd_lib
, udisks
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gvfs-${version}";
  versionMajor = "1.28";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gvfs/${versionMajor}/${name}.tar.xz";
    sha256 = "cf72fc0adf0ca702ead5b3fab3c1fa46b09678eb7c1290de7e30bb7cbaf5f704";
  };

  nativeBuildInputs = [
    docbook_xsl
    intltool
    libtool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    avahi
    dbus
    fuse
    #gconf
    gcr
    glib
    gnome-online-accounts
    gtk3
    hal
    libgdata
    libarchive
    libbluray
    libcdio
    libgudev
    libgcrypt
    libgnome-keyring
    libgphoto2
    libmtp
    libsecret
    libsoup
    libxml2
    openssh
    samba
    systemd_lib
    udisks
  ];

  configureFlags = [
    "--disable-documentation"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "gcr" (gcr != null) null)
    "--enable-nls"
    "--enable-http"
    (enFlag "avahi" (avahi != null) null)
    (enFlag "udev" (systemd_lib != null) null)
    (enFlag "fuse" (fuse != null) null)
    "--enable-gdu"
    (enFlag "udisks2" (udisks != null) null)
    (enFlag "libsystemd-login" (systemd_lib != null) null)
    (enFlag "hal" (hal != null) null)
    (enFlag "gudev" (libgudev != null) null)
    "--enable-cdda"
    "--enable-afc"
    "--enable-goa"
    "--enable-google"
    (enFlag "gphoto2" (libgphoto2 != null) null)
    (enFlag "keyring" (libgnome-keyring != null) null)
    (enFlag "bluray" (libbluray != null) null)
    "--enable-libmtp"
    (enFlag "samba" (samba != null) null)
    (enFlag "gtk" (gtk3 != null) null)
    (enFlag "archive" (libarchive != null) null)
    "--enable-afp"
    "--disable-nfs"
    "--enable-bash-completion"
    "--enable-more-warnings"
    "--enable-installed-tests"
    "--enable-always-build-tests"
    #"--with-bash-completion-dir="
  ];

  preFixup = ''
    wrapProgram $out/libexec/gvfsd \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  meta = with stdenv.lib; {
    description = "Virtual filesystem implementation for gio";
    homepage = https://git.gnome.org/browse/gvfs;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
