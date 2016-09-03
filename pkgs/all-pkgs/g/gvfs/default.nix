{ stdenv
, docbook-xsl
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
#, gnome-online-accounts
, gtk3
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
, samba_client
, systemd_lib
, udisks
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "gvfs-${version}";
  versionMajor = "1.28";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gvfs/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/gvfs/${versionMajor}/${name}.sha256sum";
    sha256 = "458c4cb68570f6ef4a9e152995c62d0057c3e0a07ed64d84c7200cdd22f0bd17";
  };

  nativeBuildInputs = [
    docbook-xsl
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
    #gnome-online-accounts
    gtk3
    libgdata
    libarchive
    libbluray
    libcdio
    #libgdata
    libgudev
    libgcrypt
    libgnome-keyring
    libgphoto2
    libmtp
    libsecret
    libsoup
    libxml2
    openssh
    samba_client
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
    (enFlag "http" (libsoup != null) null)
    (enFlag "avahi" (avahi != null) null)
    (enFlag "udev" (systemd_lib != null) null)
    (enFlag "fuse" (fuse != null) null)
    "--disable-gdu"
    (enFlag "udisks2" (
      udisks != null
      && systemd_lib != null) null)
    (enFlag "libsystemd-login" (
      systemd_lib != null
      && udisks != null) null)
    "--disable-hal"
    (enFlag "gudev" (libgudev != null) null)
    (enFlag "cdda" (
      libcdio != null
      && systemd_lib != null) null)
    "--enable-afc"
    # Remove dependency on webkit
    "--disable-goa"
    "--disable-google"
    (enFlag "gphoto2" (libgphoto2 != null) null)
    (enFlag "keyring" (libgnome-keyring != null) null)
    (enFlag "bluray" (libbluray != null) null)
    (enFlag "libmtp" (
      libmtp != null
      && systemd_lib != null) null)
    (enFlag "samba" (samba_client != null) null)
    (enFlag "gtk" (gtk3 != null) null)
    (enFlag "archive" (libarchive != null) null)
    (enFlag "afp" (libgcrypt != null) null)
    "--disable-nfs"
    "--enable-bash-completion"
    "--enable-more-warnings"
    "--disable-installed-tests"
    "--disable-always-build-tests"
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
