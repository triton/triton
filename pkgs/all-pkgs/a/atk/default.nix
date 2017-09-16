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
    "2.26" = {
      version = "2.26.0";
      sha256 = "eafe49d5c4546cb723ec98053290d7e0b8d85b3fdb123938213acb7bb4178827";
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

  postPatch = /* Remove hardcoded references to the build directory */ ''
    sed -i atk/atk-enum-types.h.template \
      -e '/@filename@/d'
  '';

  mesonFlags = [
    "-Denable_docs=false"
    "-Ddisable_introspection=false"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/atk/${channel}/"
        + "${name}.sha256sum";
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
