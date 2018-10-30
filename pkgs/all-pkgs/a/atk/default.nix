{ stdenv
, gettext
, fetchurl
, lib
, meson
, ninja

, glib
, gobject-introspection

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "2.30" = {
      version = "2.30.0";
      sha256 = "dd4d90d4217f2a0c1fee708a555596c2c19d26fef0952e1ead1938ab632c027b";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "atk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/atk/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  postPatch = /* Remove hardcoded references to the build directory, fixed in a future release */ ''
    grep -q '@filename@' atk/atk-enum-types.h.template
    sed -i atk/atk-enum-types.h.template \
      -i atk/atk-enum-types.c.template \
      -i atk/makefile.msc \
      -e 's/@filename@/@basename@/g'
  '';

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/atk/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GTK+ & GNOME Accessibility Toolkit";
    homepage = http://library.gnome.org/devel/atk/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
