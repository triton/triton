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
, zlib

, doCheck ? false
  , coreutils
  , dbus
  , desktop_file_utils
  , libxml2
  , shared_mime_info
  , tzdata
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString;
in

let
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
in

assert stdenv.cc.isGNU;

stdenv.mkDerivation rec {
  name = "glib-${version}";
  versionMajor = "2.48";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glib/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/glib/${versionMajor}/${name}.sha256sum";
    sha256 = "744be6931ca914c68af98dc38ff6b0cf8381d65e335060faddfbf04c17147c34";
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
    zlib
  ] ++ optionals doCheck [
    desktop_file_utils
    libxml2
    shared_mime_info
    tzdata
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  patches = optionals doCheck [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "glib/glib-2.x-skip-timer-test.patch";
      sha256 = "97a177c1fc229d0eef3d3d2c7a023cd6bd47ddd4ee52bd22cf82e2a0c024fb2e";
    })
  ];

  postPatch = (
    # Patch tests
    if doCheck then (
      /* Fix coreutils true path */ ''
        sed -i gio/tests/desktop-files/home/applications/epiphany-*.desktop \
          -e 's|Exec=/bin/true|Exec=${coreutils}/bin/true|'
      '' +
      /* desktop-app-info/fallback test broken upstream
       * https://github.com/GNOME/glib/commit/a036bd38a574f38773d269447cf81df023d2c819
       */ ''
        sed -i gio/tests/desktop-app-info.c \
          -e '/\/desktop-app-info\/fallback/d'
      '' +
      /* Fails to detect content type (gio sniffing) */ ''
        sed -i gio/tests/Makefile.{am,in} \
          -e '/contenttype/d'
      '' +
      /* Disable tests that require machine-id */ ''
        sed -i gio/tests/gdbus-peer.c \
          -e '/\/gdbus\/codegen-peer-to-peer/d'
        sed -i gio/tests/gdbus-unix-addresses.c \
          -e '/\/gdbus\/x11-autolaunch/d'
      '' +
      /* Regex test fails, glib/gcc5 or pcre/gcc5? */ ''
        sed -i glib/tests/regex.c \
          -e '/?<ab/d'
      '' +
      /* All gschemas fail to pass the test, upstream bug? */ ''
        sed -i gio/tests/gschema-compile.c \
          -e '/g_test_add_data_func/ s/^\/*/\/\//'
      '' +
      /* Cannot reproduce the failing test_associations on hydra */ ''
        sed -i gio/tests/appinfo.c \
          -e '/\/appinfo\/associations/d'
      '' +
      /* Needed because of libtool wrappers */ ''
        sed -i gio/tests/gsubprocess.c \
          -e '/g_subprocess_launcher_set_environ (launcher, envp);/a g_subprocess_launcher_setenv (launcher, "PATH", g_getenv("PATH"), TRUE);'
      ''
    ) else (
      /* Don't build tests, also prevents extra deps */ ''
      sed -i {.,gio,glib}/Makefile.{am,in} \
        -e 's/ tests//'
    '')
  );

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
    (enFlag "attr" (attr != null) null)
    (enFlag "libelf" (libelf != null) null)
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

  preCheck = optionalString doCheck ''
    export LD_LIBRARY_PATH="$NIX_BUILD_TOP/${name}/glib/.libs:$LD_LIBRARY_PATH"
    export TZDIR="${tzdata}/share/zoneinfo"
    export XDG_CACHE_HOME="$TMP"
    export XDG_RUNTIME_HOME="$TMP"
    export XDG_RUNTIME_DIR="$TMP"
    export HOME="$TMP"
    export XDG_DATA_DIRS="${desktop_file_utils}/share:${shared_mime_info}/share"
    export G_TEST_DBUS_DAEMON="${dbus}/bin/dbus-daemon"
    # Make sure that everything that uses D-Bus is creating its own temporary
    # session rather than polluting the developer's (or failing, on buildds)
    export DBUS_SESSION_BUS_ADDRESS='this-should-not-be-used-and-will-fail'
    # Let's get failing tests' stdout and stderr so we have some information
    # when a build fails
    export VERBOSE=1
  '';

  inherit doCheck;
  DETERMINISTIC_BUILD = 1;

  passthru = {
    gioModuleDir = "lib/gio-modules/${name}/gio/modules";
    inherit flattenInclude;
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
