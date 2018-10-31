{ stdenv
, fetchurl
, lib

, glib
, gobject-introspection
, systemd_lib
}:

let
  inherit (lib)
    boolEn;

  version = "232";
in
stdenv.mkDerivation rec {
  name = "libgudev-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgudev/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "ee4cb2b9c573cdf354f6ed744f01b111d4b5bed3503ffa956cefff50489c7860";
  };

  buildInputs = [
    glib
    gobject-introspection
    systemd_lib
  ];

  configureFlags = [
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-umockdev"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/libgudev/${version}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GObject bindings for udev";
    homepage = https://wiki.gnome.org/Projects/libgudev;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
