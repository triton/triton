{ stdenv
, fetchurl
, intltool
, lib

, glib
, gobject-introspection
, libsoup
, libxml2
}:

let
  inherit (lib)
    boolEn;

  channel = "0.8";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "rest-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/rest/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "0513aad38e5d3cedd4ae3c551634e3be1b9baaa79775e53b2dba9456f15b01c9";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    libsoup
    libxml2
  ];

  configureFlags = [
    "--${boolEn (gobject-introspection != null)}-introspection"
    # gnome support only adds a dependency on obsolete libsoup-gnome
    "--without-gnome"  # FIXME: Remove for >=0.9
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/rest/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Helper library for RESTful services";
    homepage = https://wiki.gnome.org/Projects/Librest;
    license = licenses.lgpl21;
    maintainers = with maintainers;[
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
