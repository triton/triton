{ stdenv
, docbook-xsl
, fetchurl
, intltool
, lib
, libtool
, libxslt
, makeWrapper

, avahi
, dbus
, fuse_2
, gconf
, gcr
, glib
#, gnome-online-accounts
, gtk
, libarchive
, libbluray
, libcap
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
, polkit
, samba_client
, systemd_lib
, udisks

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.32" = {
      version = "1.32.1";
      sha256 = "d0b6c9edab09d52472355657a2f0a14831b2e6c58caba395f721ab683f836ade";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gvfs-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gvfs/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    fuse_2
    #gconf
    gcr
    glib
    #gnome-online-accounts
    gtk
    libarchive
    libbluray
    libcap
    libcdio
    libgcrypt
    #libgdata  # goa
    libgnome-keyring
    libgphoto2
    libgudev
    #libimobiledevice
    #libplist
    libmtp
    #libnfs
    libsecret
    libsoup
    libxml2
    openssh
    polkit
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
    "--${boolEn (gcr != null)}-gcr"
    "--enable-nls"
    "--${boolEn (polkit != null)}-admin"
    "--${boolEn (libsoup != null)}-http"
    "--${boolEn (avahi != null)}-avahi"
    "--${boolEn (systemd_lib != null)}-udev"
    "--${boolEn (fuse_2 != null)}-fuse"
    "--disable-gdu"
    "--${boolEn (
      udisks != null
      && systemd_lib != null)}-udisks2"
    "--${boolEn (
      systemd_lib != null
      && udisks != null)}-libsystemd-login"
    "--${boolEn (
      libcdio != null
      && systemd_lib != null)}-cdda"
    "--enable-afc"
    # Remove dependency on webkit
    "--disable-goa"
    "--disable-google"
    "--${boolEn (libgphoto2 != null)}-gphoto2"
    "--${boolEn (libgnome-keyring != null)}-keyring"
    "--${boolEn (libbluray != null)}-bluray"
    "--${boolEn (
      libmtp != null
      && systemd_lib != null)}-libmtp"
    "--${boolEn (samba_client != null)}-samba"
    "--${boolEn (gtk != null)}-gtk"
    "--${boolEn (libarchive != null)}-archive"
    "--${boolEn (libgcrypt != null)}-afp"
    "--disable-nfs"
    "--enable-more-warnings"
    "--disable-installed-tests"
    "--disable-always-build-tests"
  ];

  preFixup = ''
    wrapProgram $out/libexec/gvfsd \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gvfs/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
