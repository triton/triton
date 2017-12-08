{ stdenv
, fetchurl
, intltool
, lib
# , meson
# , ninja

, glib
, gnutls
, gsettings-desktop-schemas
, libproxy
, p11-kit

, channel
}:

let
  inherit (lib)
    boolWt
    boolTf;

  sources = {
    "2.54" = {
      version = "2.54.1";
      sha256 = "eaa787b653015a0de31c928e9a17eb57b4ce23c8cf6f277afaec0d685335012f";
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
    # meson
    # ninja
  ];

  buildInputs = [
    glib
    gnutls
    gsettings-desktop-schemas
    libproxy
    p11-kit
  ];

  # postPatch = /* handled by setup-hooks */ ''
  #   sed -i meson.build \
  #     -e '/meson_post_install.py/d'
  # '';

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

  # mesonFlags = [
  #   "-Dlibproxy_support=${boolTf (libproxy != null)}"
  #   "-Dgnome_proxy_support=true"
  #   "-Dtls_support=${boolTf (gnutls != null)}"
  #   # FIXME IMPURE
  #   "-Dca_certificates_path=/etc/ssl/certs/ca-certificates.crt"
  #   "-Dpkcs11_support=${boolTf (p11-kit != null)}"
  #   "-Dinstalled_tests=false"
  # ];

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
