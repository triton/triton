{ stdenv
, fetchurl
, makeWrapper
, yasm

, alsa-lib
, bzip2
#, cairo
, dbus
, dbus-glib
, ffmpeg
, file
, fontconfig
, freetype
, glib
, gst-plugins-base
, gstreamer
, gtk3
, hunspell
, icu
, jemalloc
, libevent
, libffi
, libidl
, libjpeg
, libnotify
, libpng
#, libproxy
, pulseaudio_lib
, libstartup_notification
, libvpx
, libwebp
, mesa
, nspr
, nss
, pango
, perl
, pixman
, pythonPackages
, sqlite
, unzip
, xorg
, zip
, zlib

, channel ? "stable"

, debugBuild ? false

# If you want the resulting program to be called "Firefox" instead of
# "nightly", enable this option.  However, the resulting binaries can
# not be re-distributed without permission from the Mozilla Foundation,
# see http://www.mozilla.org/foundation/trademarks/.
, enableOfficialBranding ? false
}:

let
  inherit (stdenv.lib)
    optionals
    versionAtLeast;
  inherit (builtins.getAttr channel (import ./sources.nix))
    version
    sha512;
in

let
  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}";
in

assert stdenv.cc ? libc && stdenv.cc.libc != null;
assert (channel == "stable" || channel == "esr");

stdenv.mkDerivation rec {
  name = "firefox${if channel != "stable" then "-${channel}" else ""}-${version}";

  src = fetchurl rec {
    url = "${baseUrl}/source/firefox-${version}.source.tar.xz";
    allowHashOutput = false;
    inherit sha512;
  };

  nativeBuildInputs = [
    makeWrapper
    yasm
  ];

  buildInputs = [
    alsa-lib
    bzip2
    /* See comment in configureFlags */
    #cairo
    dbus
    dbus-glib
    ffmpeg
    file
    fontconfig
    freetype
    glib
    gst-plugins-base
    gstreamer
    gtk3
    hunspell
    icu
    jemalloc
    libevent
    libffi
    libidl
    libjpeg
    libnotify
    libpng
    #libproxy
    pulseaudio_lib
    libstartup_notification
    libvpx
    libwebp
    mesa
    nspr
    nss
    pango
    perl
    pixman
    pythonPackages.python
    pythonPackages.pysqlite
    sqlite
    stdenv.libc
    unzip
    xorg.compositeproto
    xorg.fixesproto
    xorg.kbproto
    xorg.libICE
    xorg.libSM
    xorg.libXi
    xorg.libX11
    xorg.libXrender
    xorg.libXfixes
    xorg.libXft
    xorg.libXt
    xorg.damageproto
    xorg.libXScrnSaver
    xorg.renderproto
    xorg.scrnsaverproto
    xorg.pixman
    xorg.libXext
    xorg.xextproto
    xorg.libXcomposite
    xorg.libXdamage
    xorg.xproto
    zip
    zlib
  ];

  # Firefox's bastardized autoconf script does not treat all flags
  # as booleans, so only pass flags used.
  configureFlags =
    optionals (!debugBuild) [
      "--enable-release"
    ] ++ optionals (xorg != null) [
      "--with-x"
    ] ++ optionals debugBuild [
      "--enable-profiling"
      "--enable-debug"
      "--enable-debug-symbols"
    ] ++ [
      "--enable-pie"
      "--with-pthreads"
      "--with-system-nspr"
      #"--enable-posix-nspr-emulation"
      "--with-system-libevent"
      "--with-system-nss"
    ] ++ optionals (libjpeg.type == "normal") [
      # Enable libjpeg for platforms that don't support libjpeg-turbo
      "--with-system-jpeg"
    ] ++ [
      "--with-system-zlib"
      "--with-system-bz2"
      "--with-system-png"
      "--enable-system-hunspell"
      "--enable-system-ffi"
      # Linking fails with shared js
      #"--enable-shared-js"
      #"--with-java-bin-path"
      "--enable-application=browser"
    ] ++ optionals enableOfficialBranding [
      "--enable-official-branding"
    ] ++ [
      "--enable-default-toolkit=cairo-gtk3"
    ] ++ optionals (xorg == null) [
      "--without-x"
    ] ++ [
      "--enable-startup-notification"
      # TODO: update after organization name decision
      #"--with-distribution-id=org.triton"
      "--disable-gconf"
      #"--enable-libproxy"
      #"--enable-hardware-aec-ns"
      "--enable-raw"
      "--disable-directshow"
      "--disable-wmf"
      "--enable-eme"
      #"--enable-media-navigator"
      #"--enable-omx-plugin"
      "--with-system-libvpx"
      "--enable-alsa"
      "--enable-gstreamer=1.0"
      "--disable-crashreporter"
    ] ++ optionals (libjpeg.type == "normal") [
      "--disable-libjpeg-turbo"
    ] ++ [
      #"--enable-tree-freetype"
      #"--enable-maintenance-service"
      "--disable-updater"
      "--disable-tests"
      "--enable-content-sandbox"
      "--enable-system-sqlite"
      "--enable-safe-browsing"
      "--enable-url-classifier"
      #"--with-gl-provider=ID"
      "--enable-optimize"
      "--enable-approximate-location"
      "--enable-jemalloc"
      #"--enable-clang-plugin"
      "--enable-strip"
      #"--disable-elf-hack"
      #"--enable-b2g-ril"
      #"--enable-b2g-bt"
      #"--enable-nfc"
      #"--enable-synth-pico"
      #"--enable-b2g-camera"
      #"--enable-xterm-updates"
      # TODO: add a wrapper hook to use XDG_CONFIG_HOME/mozilla instead of .mozilla
      #"--with-user-appdir=XDG_CONFIG_HOME/mozilla"
      "--enable-skia"
    ] /*++ optionals (cairo != null) [
      # Since firefox-40, using system cairo causes firefox to crash
      # frequently when it is doing background rendering in a tab.
      "--enable-system-cairo"
    ]*/ ++ [
      "--enable-system-pixman"
      #"--enable-necko-protocols={http,ftp,default,all,none}"
      "--disable-necko-wifi"
      "--with-system-icu"
      "--with-intl-api"
    ];

  preConfigure = ''
    mkdir -v ../objdir
    cd ../objdir
    configureScript=../${name}/configure
  '';

  preInstall =
    /* The following is needed for startup cache creation
       on grsecurity kernels. */ ''
      paxmark m ../objdir/dist/bin/xpcshell
    '';

  postInstall =
    /* For grsecurity kernels */ ''
      paxmark m $out/lib/${name}/{firefox,firefox-bin,plugin-container}
    '' +
    /* Remove SDK cruft. */ ''
      rm -rvf $out/share/idl $out/include $out/lib/firefox-devel-*
    '' +
    /* GTK3: argv[0] must point to firefox itself */ ''
      wrapProgram "$out/bin/firefox" \
        --argv0 "$out/bin/.firefox-wrapped" \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix XDG_DATA_DIRS : "$out/share" \
        --suffix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    '' +
    /* Simple test */ ''
      "$out/bin/firefox" --version
    '';

  NIX_CFLAGS_COMPILE = "-fno-schedule-insns2 -fno-delete-null-pointer-checks";

  parallelBuild = false;

  passthru = {
    inherit
      nspr
      version;

    srcVerified = fetchurl rec {
      failEarly = true;
      sha512Url = "${baseUrl}/SHA512SUMS";
      pgpsigSha512Url = "${sha512Url}.asc";
      pgpKeyFingerprint = "14F2 6682 D091 6CDD 81E3  7B6D 61B7 B526 D98F 0353";
      inherit (src) urls outputHashAlgo outputHash;
    };
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
    platforms = with platforms;
      x86_64-linux;
  };
}
