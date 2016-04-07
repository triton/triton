{ stdenv
, fetchurl
, intltool

, glib
, gnutls
, gsettings-desktop-schemas
, libproxy
, p11_kit
}:

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "glib-networking-${version}";
  versionMajor = "2.48";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib-networking/${versionMajor}/${name}.tar.xz";
    sha256 = "7a1f3312e757b97af94e2db8a1f14eb9cc018c983931ecdf3b0c54acece39024";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gnutls
    gsettings-desktop-schemas
    libproxy
    p11_kit
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-glibtest"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-gcov"
    "--enable-more-warnings"
    (wtFlag "libproxy" (libproxy != null) null)
    "--with-gnome-proxy"
    (wtFlag "gnutls" (gnutls != null) null)
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
    (wtFlag "pkcs11" (p11_kit != null) null)
  ];

  preBuild = ''
    sed -i $(find . -name Makefile) \
      -e "s|${glib}/lib/gio/modules|$out/lib/gio/modules|g"
  '';

  doCheck = false; # tests need to access the certificates (among other things)

  meta = with stdenv.lib; {
    description = "Network-related giomodules for glib";
    homepage = https://git.gnome.org/browse/glib-networking/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
