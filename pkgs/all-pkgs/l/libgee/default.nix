{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, glib
, gobject-introspection
, vala

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "0.18" = {
      version = "0.18.1";
      sha256 = "99686bbe5a9c89ba9502c25f61314ee8efa0dd2a1159c9a639afc1458c2839a2";
    };
    "0.20" = {
      version = "0.20.1";
      sha256 = "bb2802d29a518e8c6d2992884691f06ccfcc25792a5686178575c7111fea4630";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgee-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgee/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
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
    "--disable-consistency-check"
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

  meta = with lib; {
    description = "GObject-based interfaces/classes for common data structures";
    homepage = https://wiki.gnome.org/Projects/Libgee;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
