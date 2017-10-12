{ stdenv
, fetchFromGitHub
, gettext
, meson
, ninja
, python3Packages

, appstream-glib
, cairo
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
  version = "1.0.0";
in
stdenv.mkDerivation rec {
  name = "fwupd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "hughsie";
    repo = "fwupd";
    rev = version;
    sha256 = "5779cf25d3cc645bac24e93c44d0db3b7bb4b620c3611587dfcb2152b271067a";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    python3Packages.pygobject
    python3Packages.python
  ];

  buildInputs = [
    appstream-glib
    cairo
    efivar
    elfutils
    fontconfig
    freetype
    fwupdate
    gcab
    gdk-pixbuf
    glib
    gnutls
    gobject-introspection
    gpgme
    libarchive
    libgpg-error
    libgudev
    libgusb
    libsmbios
    libsoup
    libusb
    pango
    polkit
    sqlite
    systemd_lib
    systemd-dummy
    util-linux_lib
  ];

  postPatch = ''
    patchShebangs po/test-deps
  '';

  mesonFlags = [
    "-Denable-doc=false"
    "-Denable-tests=false"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
