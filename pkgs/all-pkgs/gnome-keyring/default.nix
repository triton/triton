{ stdenv
, fetchurl
, gettext
, intltool
, libxslt

, gcr
, glib
, libcap_ng
, libgcrypt
, p11_kit
, pam
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-keyring-${version}";
  versionMajor = "3.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-keyring/${versionMajor}/${name}.tar.xz";
    sha256 = "167dq1yvm080g5s38hqjl0xx5cgpkcl1xqy9p5sxmgc92zb0srrz";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    gcr
    glib
    libcap_ng
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
    (wtFlag "libcap-ng" (libcap_ng != null) null)
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
