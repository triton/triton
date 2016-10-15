{ stdenv
, fetchTritonPatch
, fetchurl

, glib
, gobject-introspection
, vala

, channel
}:

let
  inherit (stdenv.lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgee-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgee/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    glib
    gobject-introspection
    vala
  ];

  patches = [
    (fetchTritonPatch {
      rev = "734f89c9d36781e3f50f30dc9aa33d071136dbd0";
      file = "libgee/fix_introspection_paths.patch";
      sha256 = "4164fb22b29a9dac7b6940bbb848a4d1fcb8cc81b207db7d69d7ab67c4aa4aed";
    })
  ];

  configureFlags = [
    "--disable-doc"
    "--disable-coverage"
    "--disable-benchmark"
    "--enable-internal-asserts"
    "--disable-consistency-checks"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-vala-fatal-warnings"
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgee/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "GObject-based interfaces and classes for common data structures";
    homepage = https://wiki.gnome.org/Projects/Libgee;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
