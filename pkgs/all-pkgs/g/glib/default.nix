{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, meson
, ninja

, elfutils
, libffi
, libselinux
, pcre
, python3
, util-linux_lib
, zlib
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals
    optionalString;

  # Some packages don't get "Cflags" from pkgconfig correctly
  # and then fail to build when directly including like <glib/...>.
  # This is intended to be run in postInstall of any package
  # which has $out/include/ containing just some disjunct directories.
  flattenInclude = ''
    for dir in "$out"/include/* ; do
      cp -r "$dir"/* "$out/include/"
      rm -r "$dir"
      ln -s . "$dir"
    done
    ln -sr -t "$out/include/" "$out"/lib/*/include/* 2>/dev/null || true
  '';

  channel = "2.60";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "2b941ec5dcb92e5ea83fe42f9eb55a827bc8a12c153ad2489d551c31d04733dd";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    elfutils
    libffi
    libselinux
    pcre
    # Needed for bin tooling like `glib-mkenums` in the output
    python3
    util-linux_lib
    zlib
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  # Don't build a bunch of unused test / fuzzing code
  postPatch = ''
    find . -name meson.build -exec sed -i "/subdir('\(fuzzing\|tests\)')/d" {} \;
  '';

  postInstall = ''
    # Exit the ninja build directory
    cd ../$srcRoot
    # M4 macros are not installed by meson, but still needed by other
    # packages during the meson transition.
    for i in 'glib-2.0.m4' 'glib-gettext.m4' 'gsettings.m4'; do
      ! test -e "$out"/share/aclocal/"$i"
      install -D -m 644 -v m4macros/"$i" "$out"/share/aclocal/"$i"
    done
  '';

  passthru = {
    gioModuleDir = "lib/gio-modules/${name}/gio/modules";
    inherit flattenInclude;

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/glib/${channel}/"
          + "${name}.sha256sum";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "C library of programming buildings blocks";
    homepage = http://www.gtk.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
