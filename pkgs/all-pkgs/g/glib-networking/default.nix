{ stdenv
, fetchurl
, intltool

, glib
, gnutls
, gsettings-desktop-schemas
, libproxy
, p11_kit

, channel
}:

let
  inherit (stdenv.lib)
    boolWt;

  source = (import ./sources.nix { })."${channel}";
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
    "--${boolWt (libproxy != null)}-libproxy"
    "--with-gnome-proxy"
    "--${boolWt (gnutls != null)}-gnutls"
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
    "--${boolWt (p11_kit != null)}-pkcs11"
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
