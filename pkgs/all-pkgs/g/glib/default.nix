{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, meson
, ninja
, python3

, attr
, elfutils
, libffi
, libselinux
, pcre
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

  channel = "2.56";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "ecef6e17e97b8d9150d0e8a4b3edee1ac37331213b8a2a87a083deea408a0fc7";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    elfutils  # FIXME: only need libelf
    libffi
    libselinux
    pcre
    stdenv.libc
    util-linux_lib
    zlib
  ] ++ optionals stdenv.cc.isGNU [  # FIXME: need a proper way to test current libc
    # libattr is only needed for systems that don't use glibc
    attr
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  postPatch = ''
    sed -i gio/tests/gengiotypefuncs.py \
      -e 's,#!/usr/bin/env python.*,#!${python3.interpreter},'
  '';

  mesonFlags = [
    "-Diconv=libc"  # FIXME: assumes glibc is libc
    "-Dselinux=true"
    "-Dxattr=true"
    "-Dlibmount=true"
    # The internal pcre is not patched to support gcc5, among other
    "-Dinternal_pcre=false"
    "-Dman=false"
    "-Dsystemtap=false"
    "-Dgtk_doc=false"
  ];

  postInstall = ''
    rm -rvf $out/share/gtk-doc

    # Exit the ninja build directory
    cd ../$srcRoot
    # M4 macros are not installed by meson, but still needed by other
    # packages during the meson transition.
    for i in 'glib-2.0.m4' 'glib-gettext.m4' 'gsettings.m4'; do
      ls -al
      install -D -m 644 -v m4macros/$i $out/share/aclocal/$i
    done
  '';

  passthru = {
    gioModuleDir = "lib/gio-modules/${name}/gio/modules";
    inherit flattenInclude;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/glib/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
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
