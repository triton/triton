{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, lib

, avahi
, gcr
, glib
, gnupg
, gpgme
, gtk3
, libsecret
, libsoup
, libxml2
, openldap
, openssh
, shared-mime-info
, vala
}:

let
  channel = "3.20";
  version = "${channel}.0";
in

stdenv.mkDerivation rec {
  name = "seahorse-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/seahorse/${channel}/${name}.tar.xz";
    #sha256Url = "mirror://gnome/sources/seahorse/${versionMajor}/${name}.sha256sum";
    sha256 = "e2b07461ed54a8333e5628e9b8e517ec2b731068377bf376570aad998274c6df";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    vala
  ];

  buildInputs = [
    avahi
    gcr
    glib
    gnupg
    gpgme
    gtk3
    libsecret
    libsoup
    libxml2
    openldap
    openssh
    shared-mime-info
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-valac"
    "--disable-code-coverage"
    "--enable-schemas-compile"
    "--enable-largefile"
    "--enable-pgp"
    "--enable-gpg-check"
    "--enable-ldap"
    "--enable-hkp"
    "--enable-sharing"
    "--enable-sharing"
    "--enable-pkcs11"
    "--enable-pkcs11"
    "--enable-ssh"
    "--disable-debug"
    "--disable-strict"
    "--disable-coverage"
    "--without-gcov"
  ];

  doCheck = true;

  meta = with lib; {
    description = "A GNOME application for managing encryption keys";
    homepage = https://wiki.gnome.org/Apps/Seahorse;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
