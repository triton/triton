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
    "2.28" = {
      version = "2.28.1";
      sha256 = "cd3a1ea6ecc268a2497f0cd018e970860de24a6d42086919d6bf6c8e8d53f4fc";
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
