{ stdenv
#, autoconf
#, automake113x
, fetchTritonPatch
, fetchurl
, gettext
, lib

, glib
, gobject-introspection
, gssdp
, gupnp
#, python
#, pythonPackages
}:

let
  channel = "0.2";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "gupnp-igd-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-igd/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "8b4a1aa38bacbcac2c1755153147ead7ee9af7d4d1f544b6577cfc35e10e3b20";
  };

  nativeBuildInputs = [
    gettext
  ]/* ++ optionals (python != null) [
    autoconf
    automake113x
  ]*/;

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    gupnp
    #python
    #pythonPackages.pygobject
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ef3e1239166507b0bcfe63661ad6d7c4959a4c3f";
      file = "gupnp-igd/gupnp-igd-0.1.11-disable_static_modules.patch";
      sha256 = "c7a2802e832c27000765f7988025e3c8fe24953224958523e6f3cc739c4d05bd";
    })
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    # TODO: python support
    #"--${boolEn (python != null)}-python"
    "--disable-python"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gupnp-igd/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "";
    homepage = http://www.gupnp.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
