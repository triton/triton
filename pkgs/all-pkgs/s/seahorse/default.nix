{ stdenv
, fetchurl
, gettext
, intltool
, itstool

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
, shared_mime_info
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "seahorse-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/seahorse/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/seahorse/${versionMajor}/${name}.sha256sum";
    sha256 = "e2b07461ed54a8333e5628e9b8e517ec2b731068377bf376570aad998274c6df";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
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
    shared_mime_info
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    (enFlag "valac" (vala != null) null)
    "--disable-code-coverage"
    "--enable-schemas-compile"
    "--enable-largefile"
    (enFlag "pgp" (
      gnupg != null
      && gpgme != null) null)
    (enFlag "gpg-check" (
      gnupg != null
      && gpgme != null) null)
    (enFlag "ldap" (openldap != null) null)
    (enFlag "hkp" (libsoup != null) null)
    "--enable-sharing"
    (enFlag "sharing" (
      avahi != null
      && gnupg != null
      && gpgme != null
      && libsoup != null) null)
    "--enable-pkcs11"
    (enFlag "pkcs11" (gcr != null) null)
    (enFlag "ssh" (openssh != null) null)
    "--disable-debug"
    "--disable-strict"
    "--disable-coverage"
    "--without-gcov"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
