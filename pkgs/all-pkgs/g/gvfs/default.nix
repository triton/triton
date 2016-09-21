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
, gtk
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

, channel
}:

let
  inherit (stdenv.lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
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
    fuse
    #gconf
    gcr
    glib
    #gnome-online-accounts
    gtk
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
    "--${boolEn (gcr != null)}-gcr"
    "--enable-nls"
    "--${boolEn (libsoup != null)}-http"
    "--${boolEn (avahi != null)}-avahi"
    "--${boolEn (systemd_lib != null)}-udev"
    "--${boolEn (fuse != null)}-fuse"
    "--disable-gdu"
    "--${boolEn (
      udisks != null
      && systemd_lib != null)}-udisks2"
    "--${boolEn (
      systemd_lib != null
      && udisks != null)}-libsystemd-login"
    "--disable-hal"
    "--${boolEn (libgudev != null)}-gudev"
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
