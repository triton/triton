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
, libarchive
, libbluray
, libcdio
, libgcrypt
, libgdata
, libgnome_keyring
, libgphoto2
, libgudev
, libmtp
, libsecret
, libsoup
, libxml2
, openssh
, samba
, systemd
, udev
, udisks2
}:

stdenv.mkDerivation rec {
  name = "gvfs-${version}";
  versionMajor = "1.26";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gvfs/${versionMajor}/${name}.tar.xz";
    sha256 = "064dsjrdjcbi38zl38jhh4r9jcpiygg7x4c8s6s2rb757l7nwnv9";
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
    gcr
    glib
    gnome-online-accounts
    libgdata
    libarchive
    libbluray
    libcdio
    libgudev
    libgcrypt
    libgphoto2
    libmtp
    libsecret
    libsoup
    libxml2
    openssh
    samba
    systemd
    udev
    udisks2
    #gconf
    gtk3
    libgnome_keyring
  ];

  configureFlags = [
    "--disable-documentation"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gcr"
    "--enable-nls"
    "--enable-http"
    "--enable-avahi"
    "--enable-udev"
    "--enable-fuse"
    "--enable-gdu"
    "--enable-udisks2"
    "--enable-libsystemd-login"
    "--enable-hal"
    "--enable-gudev"
    "--enable-cdda"
    "--enable-afc"
    "--enable-goa"
    "--enable-google"
    "--enable-gphoto2"
    "--enable-keyring"
    "--enable-bluray"
    "--enable-libmtp"
    "--enable-samba"
    "--enable-gtk"
    "--enable-archive"
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
      i686-linux
      ++ x86_64-linux;
  };
}
