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
, libusb
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
    "1.34" = {
      version = "1.34.2";
      sha256 = "60d3c7eaf3dc697653b330b55b806ab0a59424030954628eb5ed88e8ea3a9669";
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
    libusb
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
    "--enable-gudev"
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
    "--enable-libusb"
    "--${boolEn (
      libmtp != null
      && systemd_lib != null)}-libmtp"
    "--${boolEn (samba_client != null)}-samba"
    "--${boolEn (libarchive != null)}-archive"
    "--${boolEn (libgcrypt != null)}-afp"
    "--disable-nfs"
    "--enable-more-warnings"
    "--disable-installed-tests"
    "--disable-always-build-tests"
  ];

  preFixup = ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --prefix 'PATH' : "${glib}/bin"
    done

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
