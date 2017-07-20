{ stdenv
, fetchurl
, intltool
, lib

, glib
, gnutls
, gsettings-desktop-schemas
, libproxy
, p11-kit

, channel
}:

let
  inherit (lib)
    boolWt;

  sources = {
    "2.50" = {
      version = "2.50.0";
      sha256 = "3f1a442f3c2a734946983532ce59ed49120319fdb10c938447c373d5e5286bee";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "glib-networking-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib-networking/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gnutls
    gsettings-desktop-schemas
    libproxy
    p11-kit
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-glibtest"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-gcov"
    "--enable-more-warnings"
    "--${boolWt (libproxy != null)}-libproxy"
    "--with-gnome-proxy"
    "--${boolWt (gnutls != null)}-gnutls"
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
    "--${boolWt (p11-kit != null)}-pkcs11"
  ];

  preBuild = ''
    sed -i $(find . -name Makefile) \
      -e "s|${glib}/lib/gio/modules|$out/lib/gio/modules|g"
  '';

  doCheck = false; # tests need to access the certificates (among other things)

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/glib-networking/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
