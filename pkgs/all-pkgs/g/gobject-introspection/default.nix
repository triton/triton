{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, lib
, meson
, ninja

, glib
, libffi
, python3
}:

let
  inherit (lib)
    boolWt
    optionals
    optionalString;

  channel = "1.60";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "gobject-introspection-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gobject-introspection/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d844d1499ecd36f3ec8a3573616186d36626ec0c9a7981939e99aa02e9c824b3";
  };

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
  ];

  buildInputs = [
    glib
    libffi
    python3
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gobject-introspection/gobject-introspection-1.x-absolute_shlib_path.patch";
      sha256 = "72be007720645946a4db10e4d845a78ef0d74867db915f414c1ec485f8a2494e";
    })
  ];

  # Don't build a bunch of unused test / example code
  postPatch = ''
    find . -name meson.build -exec sed -i "/subdir('\(examples|tests\)')/d" {} \;
  '';

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gobject-introspection/"
          + "${channel}/${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage = http://live.gnome.org/GObjectIntrospection;
    license = with licenses; [
      lgpl2Plus
      gpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
