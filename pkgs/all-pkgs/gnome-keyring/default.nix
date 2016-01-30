{ stdenv, fetchurl, pkgconfig, dbus, libgcrypt, libtasn1, pam, python, glib, libxslt
, intltool, pango, gcr, gdk_pixbuf, atk, p11_kit, makeWrapper
, docbook_xsl_ns, docbook_xsl, gtk3, gconf, libgnome_keyring }:

stdenv.mkDerivation rec {
  name = "gnome-keyring-${version}";
  versionMajor = "3.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-keyring/${versionMajor}/${name}.tar.xz";
    sha256 = "167dq1yvm080g5s38hqjl0xx5cgpkcl1xqy9p5sxmgc92zb0srrz";
  };

  buildInputs = [
    dbus libgcrypt pam python gtk3 gconf libgnome_keyring
    pango gcr gdk_pixbuf atk p11_kit makeWrapper
  ];

  propagatedBuildInputs = [ glib libtasn1 libxslt ];

  nativeBuildInputs = [ pkgconfig intltool docbook_xsl_ns docbook_xsl ];

  configureFlags = [
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt" # NixOS hardcoded path
    "--with-pkcs11-config=$$out/etc/pkcs11/" # installation directories
    "--with-pkcs11-modules=$$out/lib/pkcs11/"
  ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    #maintainers = gnome3.maintainers;
  };
}
