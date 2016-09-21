{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, perl
, python

, attr
, libelf
, libffi
, pcre
, util-linux_lib
, zlib

, channel
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals
    optionalString
    versionAtLeast;

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

  source = (import ./sources.nix { })."${channel}";
in

assert stdenv.cc.isGNU;

stdenv.mkDerivation rec {
  name = "glib-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    perl
    python
  ];

  buildInputs = [
    attr
    libelf
    libffi
    pcre
    util-linux_lib
    zlib
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  postPatch = /* Don't build tests, also prevents extra deps */ ''
    sed -i {.,gio,glib}/Makefile.{am,in} \
      -e 's/ tests//'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-gc-friendly"
    #"--enable-mem-pools"
    "--enable-rebuilds"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--enable-largefile"
    "--disable-included-printf"
    "--disable-selinux"
    "--disable-fam"
    "--${boolEn (attr != null)}-xattr"
    "--${boolEn (libelf != null)}-libelf"
    (if versionAtLeast channel "2.50" then
      "--${boolEn (util-linux_lib != null)}-libmount"
     else
       null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--disable-dtrace"
    "--disable-systemtap"
    "--disable-coverage"
    "--enable-Bsymbolic"
    #"--disable-znodelete"
    "--enable-compile-warnings"
    # The internal pcre is not patched to support gcc5, among other
    # fixes specific to Triton
    "--with-pcre=system"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  bindnow = false;
  pie = false;

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
