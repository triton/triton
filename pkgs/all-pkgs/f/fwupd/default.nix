{ stdenv
, fetchFromGitHub
, gettext
, meson
, ninja
, python3Packages

, appstream-glib
, cairo
, colord
, efivar
, elfutils
, fontconfig
, freetype
, fwupdate
, gcab
, gdk-pixbuf
, glib
, gnutls
, gobject-introspection
, gpgme
, libarchive
, libgpg-error
, libgudev
, libgusb
, libsmbios
, libsoup
, libusb
, pango
, polkit
, sqlite
, systemd_lib
, systemd-dummy
, util-linux_lib
}:

let
  version = "1.0.2";
in
stdenv.mkDerivation rec {
  name = "fwupd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "hughsie";
    repo = "fwupd";
    rev = version;
    sha256 = "59be5b458dc816822e01761ac34eb41bcc4de255d064847a64ae0f631d0b0dd7";
  };

  nativeBuildInputs = [
    gettext
    gobject-introspection
    meson
    ninja
    python3Packages.pygobject
    python3Packages.python
  ];

  buildInputs = [
    appstream-glib
    cairo
    colord
    #efivar
    elfutils
    fontconfig
    freetype
    fwupdate
    gcab
    #gdk-pixbuf
    glib
    gnutls
    gpgme
    libarchive
    libgpg-error
    libgudev
    libgusb
    #libsmbios
    libsoup
    #libusb
    pango
    polkit
    sqlite
    #systemd_lib
    systemd-dummy
    util-linux_lib
  ];

  mesonFlags = [
    "-Dgtkdoc=false"
    "-Dtests=false"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
