{ stdenv
, fetchurl
, makeWrapper

, channel ? "stable"

, gtk2
, gtk3
, pango
, perl
, python
, zip
, libIDL
, libjpeg
, zlib
, dbus
, dbus_glib
, bzip2
, xorg
, freetype
, fontconfig
, file
, alsaLib
, nspr
, nss
, libnotify
, yasm
, mesa
, sqlite
, unzip
, pysqlite
, hunspell
, libevent
, libstartup_notification
, libvpx
, cairo
, gstreamer_0
, gst-plugins-base_0
, icu
, libpng
, jemalloc
, libpulseaudio
, libffi

, debugBuild ? false
, # If you want the resulting program to call itself "Firefox" instead of
  # "nightly", enable this option.  However, those binaries may not be
  # distributed without permission from the Mozilla Foundation, see
  # http://www.mozilla.org/foundation/trademarks/.
  enableOfficialBranding ? false
}:

with {
  inherit (stdenv)
    isi686;
  inherit (stdenv.lib)
    optional
    optionalString
    versionAtLeast;
  inherit (builtins.getAttr channel (import ./sources.nix))
    version
    sha512;
};

assert stdenv.cc ? libc && stdenv.cc.libc != null;
assert (channel == "stable" || channel == "esr");

stdenv.mkDerivation rec {
  name = "firefox${if channel != "stable" then "-${channel}" else ""}-${version}";

  src = fetchurl {
    url =
      let
        ext = if versionAtLeast version "41.0" then "xz" else "bz2";
      in
      "http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}/source/firefox-${version}.source.tar.${ext}";
    inherit sha512;
  };

  configureFlags = [
    "--enable-application=browser"
    "--disable-javaxpcom"
    "--with-system-jpeg"
    "--with-system-zlib"
    "--with-system-bz2"
    "--with-system-nspr"
    "--with-system-nss"
    "--with-system-libevent"
    "--with-system-libvpx"
    "--with-system-png" # needs APNG support
    "--with-system-icu"
    "--enable-system-ffi"
    "--enable-system-hunspell"
    "--enable-system-pixman"
    "--enable-system-sqlite"
    #"--enable-system-cairo"
    "--enable-gstreamer"
    "--enable-startup-notification"
    "--enable-content-sandbox"            # available since 26.0, but not much info available
    "--disable-content-sandbox-reporter"  # keeping disabled for now
    "--disable-crashreporter"
    "--disable-tests"
    "--disable-necko-wifi" # maybe we want to enable this at some point
    "--disable-installer"
    "--disable-updater"
    "--enable-jemalloc"
    "--disable-gconf"
    "--enable-default-toolkit=cairo-gtk3"
  ] ++ (if debugBuild then [
    "--enable-debug"
    "--enable-profiling"
  ] else [
    "--disable-debug"
    "--enable-release"
    "--enable-optimize${optionalString isi686 "=-O1"}"
    "--enable-strip"
  ]) ++ optional enableOfficialBranding "--enable-official-branding";

  preConfigure = ''
    mkdir ../objdir
    cd ../objdir
    if [ -e ../${name} ] ; then
      configureScript=../${name}/configure
    else
      configureScript=../mozilla-*/configure
    fi
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    gtk2
    gtk3
    perl
    zip
    libIDL
    libjpeg
    zlib
    bzip2
    python
    dbus
    dbus_glib
    pango
    freetype
    fontconfig
    xorg.libXi
    xorg.libX11
    xorg.libXrender
    xorg.libXft
    xorg.libXt
    xorg.libXScrnSaver
    xorg.scrnsaverproto
    xorg.pixman
    xorg.libXext
    xorg.xextproto
    xorg.libXcomposite
    xorg.libXdamage
    file
    alsaLib
    nspr
    nss
    libnotify
    yasm
    mesa
    pysqlite
    sqlite
    unzip
    hunspell
    libevent
    libstartup_notification
    libvpx
    /* cairo */
    gstreamer_0
    gst-plugins-base_0
    icu
    libpng
    jemalloc
    libpulseaudio # only headers are needed
    libffi
  ];

  preInstall =
  /* The following is needed for startup cache creation
     on grsecurity kernels. */ ''
    paxmark m ../objdir/dist/bin/xpcshell
  '';

  postInstall =
  /* For grsecurity kernels */ ''
    paxmark m $out/lib/${name}/{firefox,firefox-bin,plugin-container}
  '' +
  /* Remove SDK cruft. FIXME: move to a separate output? */ ''
    rm -rf $out/share/idl $out/include $out/lib/firefox-devel-*
  '' +
  /* GTK3: argv[0] must point to firefox itself */ ''
    wrapProgram "$out/bin/firefox" \
      --argv0 "$out/bin/.firefox-wrapped" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:" \
      --suffix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '' +
  /* Basic test */ ''
    "$out/bin/firefox" --version
  '';

  disableGnomeWrapper = true;
  enableParallelBuilding = true;

  passthru = {
    inherit
      gtk2
      nspr
      version;
    isFirefox3Like = true;
  };

  meta = with stdenv.lib; {
    description = "Firefox Web Browser";
    homepage = http://www.mozilla.com/en-US/firefox/;
    license = with licenses; [
      gpl2
      lgpl21
      mpl20
    ];
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
