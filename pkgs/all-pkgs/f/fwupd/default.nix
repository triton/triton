{ stdenv
, fetchFromGitHub
, gettext
, meson
, ninja
, python3Packages

, appstream-glib
, cairo
, efivar
, fontconfig
, freetype
, fwupdate
, gcab
, gdk-pixbuf
, glib
, gobject-introspection
, gpgme
, libarchive
, libelf
, libgpg-error
, libgudev
, libgusb
, libsmbios
, libsoup
, libusb
, pango
, polkit
, sqlite
, systemd_full
, util-linux_lib
}:

let
  version = "0.9.7";
in
stdenv.mkDerivation rec {
  name = "fwupd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "hughsie";
    repo = "fwupd";
    rev = version;
    sha256 = "980393b4ea3d58b1be26598daaed4fb36932cf893dfd97f534ff01ba7ff9719d";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    appstream-glib
    cairo
    efivar
    fontconfig
    freetype
    fwupdate
    gcab
    gdk-pixbuf
    glib
    gobject-introspection
    gpgme
    libarchive
    libelf
    libgpg-error
    libgudev
    libgusb
    libsmbios
    libsoup
    libusb
    pango
    polkit
    python3Packages.pillow
    python3Packages.pycairo
    python3Packages.pygobject
    python3Packages.python
    sqlite
    systemd_full
    util-linux_lib
  ];

  postPatch = ''
    patchShebangs po/test-deps
  '';

  mesonFlags = [
    "-Denable-colorhug=false"
    "-Denable-uefi=${if fwupdate != null then "true" else "false"}"
    "-Denable-dell=${if fwupdate != null then "true" else "false"}"
    "-Denable-thunderbolt=false"
    "-Denable-doc=false"
    "-Denable-man=false"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
