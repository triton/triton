{ stdenv
, fetchurl
, intltool

, glib
, gnutls
, gsettings_desktop_schemas
, libproxy
, p11_kit
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "glib-networking-${version}";
  versionMajor = "2.46";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib-networking/${versionMajor}/${name}.tar.xz";
    sha256 = "1cchmi08jpjypgmm9i7xzh5qfg2q5k61kry9ns8mhw3z44a440ym";
  };

  configureFlags = [
    "--enable-nls"
    "--disable-glibtest"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-gcov"
    (wtFlag "libproxy" (libproxy != null) null)
    "--with-gnome-proxy"
    (wtFlag "gnutls" (gnutls != null) null)
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
    (wtFlag "pkcs11" (p11_kit != null) null)
  ];

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gnutls
    gsettings_desktop_schemas
    libproxy
    p11_kit
  ];

  preBuild = ''
    sed -e "s|${glib}/lib/gio/modules|$out/lib/gio/modules|g" \
      -i $(find . -name Makefile)
  '';

  doCheck = false; # tests need to access the certificates (among other things)
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Network-related giomodules for glib";
    homepage = https://git.gnome.org/browse/glib-networking/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
