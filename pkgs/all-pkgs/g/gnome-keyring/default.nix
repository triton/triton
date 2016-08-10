{ stdenv
, fetchurl
, gettext
, intltool
, libxslt

, gcr
, glib
, libcap-ng
, libgcrypt
, p11_kit
, pam
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "gnome-keyring-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-keyring/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-keyring/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "bc17cecd748a0e46e302171d11c3ae3d76bba5258c441fabec3786f418e7ec99";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    gcr
    glib
    libcap-ng
    libgcrypt
    p11_kit
    pam
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    (enFlag "pam" (pam != null) null)
    "--enable-ssh-agent"
    "--disable-selinux"
    "--disable-p11-tests"
    "--disable-doc"
    "--disable-debug"
    "--disable-coverage"
    "--disable-valgrind"
    #"--with-dbus-services="
    #"--with-pam-dir="
    "--with-pkcs11-config=\${out}/etc/pkcs11/"
    "--with-pkcs11-modules=\${out}/lib/pkcs11/"
    (wtFlag "libcap-ng" (libcap-ng != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Password and keyring managing daemon";
    homepage = https://wiki.gnome.org/Projects/GnomeKeyring;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
