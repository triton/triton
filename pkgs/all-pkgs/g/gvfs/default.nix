{ stdenv
, docbook-xsl
, fetchurl
, gettext
, intltool
, itstool
, lib
, libxslt
, makeWrapper
, meson
, ninja
, python3

, avahi
, dbus
, fuse_2
, gconf
, gcr
, glib
#, gnome-online-accounts
, libarchive
#, libbluray
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
#, samba_client
, systemd-dummy
, systemd_lib
, udisks
}:

let
  inherit (lib)
    boolEn;

  channel = "1.38";
  version = "${channel}.1";
  sha256 = "ed136a842c996d25c835da405c4775c77106b46470e75bdc242bdd59ec0d61a0";
in
stdenv.mkDerivation rec {
  name = "gvfs-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gvfs/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit sha256;
  };

  nativeBuildInputs = [
    docbook-xsl
    gettext
    intltool
    itstool
    libxslt
    makeWrapper
    meson
    ninja
    python3  # FIXME: remove for 1.40.x
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
    #libbluray
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
    #samba_client
    systemd-dummy
    systemd_lib
    udisks
  ];

  postPatch = ''
    # FIXME: remove for 1.40.x
    patchShebangs codegen.py

    # Already handled by setup-hooks
    grep -q 'meson_post_install.py' meson.build
    sed -i meson.build \
      -e '/meson.add_install_script/,+4 d'
  '';

  mesonFlags = [
    "-Dadmin=false"  # FIXME
    "-Dafc=false"  # FIXME
    "-Dcdda=false"  # FIXME
    # Remove dependency on webkit2
    "-Dgoa=false"
    "-Dgoogle=false"
    "-Dnfs=false"
    "-Dsmb=false"  # FIXME
    "-Dbluray=false"  # FIXME
    "-Dman=true"
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
