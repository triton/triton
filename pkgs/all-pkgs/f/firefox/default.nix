{ stdenv
, autoconf_21x
, fetchurl
, makeWrapper
, perl
, pythonPackages
, rustc
, which
, unzip
, yasm
, zip

, alsa-lib
, atk
, bzip2
#, cairo
, dbus
, dbus-glib
, fontconfig
, freetype
, gconf
, glib
, gtk2
, gtk3
, hunspell
, icu
, jemalloc
, libevent
, libffi
, libjpeg
, libpng
, libproxy
, pulseaudio_lib
, libstartup_notification
, libvpx
, nspr
, nss
, pango
, readline
, sqlite
, xorg
, zlib

, channel ? "stable"
}:

let
  inherit (stdenv.lib)
    optionals
    versionAtLeast;

  inherit (builtins.getAttr channel (import ./sources.nix))
    version
    sha512;

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}";
in
stdenv.mkDerivation rec {
  name = "firefox-${version}";

  src = fetchurl rec {
    url = "${baseUrl}/source/firefox-${version}.source.tar.xz";
    hashOutput = false;
    inherit sha512;
  };

  nativeBuildInputs = [
    autoconf_21x
    makeWrapper
    perl
    pythonPackages.python
    rustc
    which
    unzip
    yasm
    zip
  ];

  AUTOCONF = "${autoconf_21x}/bin/autoconf";

  buildInputs = [
    alsa-lib
    atk
    bzip2
    # cairo  # See configureFlags
    dbus
    dbus-glib
    fontconfig
    freetype
    gconf
    glib
    gtk2
    gtk3
    hunspell
    icu
    libevent
    libffi
    libjpeg
    libpng
    libproxy
    libstartup_notification
    libvpx
    nspr
    nss
    pango
    pulseaudio_lib
    readline
    sqlite
    xorg.compositeproto
    xorg.damageproto
    xorg.fixesproto
    xorg.kbproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXt
    xorg.pixman
    xorg.renderproto
    xorg.scrnsaverproto
    xorg.xextproto
    xorg.xproto
    zlib
  ];

  preConfigure = ''
    mkdir -v ../objdir
    cd ../objdir
    configureScript=../${name}/configure
  '';

  configureFlags = [
    "--enable-default-toolkit=cairo-gtk3"
    "--enable-eme=widevine"
    "--disable-tests"
    "--enable-jemalloc=4"
    "--enable-system-hunspell"
    "--enable-alsa"
    "--enable-approximate-location"
    "--enable-content-sandbox"
    "--enable-cookies"
    "--disable-crashreporter"
    "--enable-dbm"
    "--enable-dbus"
    "--enable-faststripe"
    "--enable-feeds"
    "--enable-gamepad"
    "--enable-gconf"
    "--enable-gczeal"
    "--enable-gio"
    "--enable-gold"
    "--enable-icf"
    "--enable-install-strip"
    "--enable-ion"
    "--enable-libproxy"
    "--enable-media-navigator"
    "--enable-more-deterministic"
    "--enable-negotiateauth"
    "--enable-nfc"
    "--enable-official-branding"
    "--enable-optimize"
    "--enable-permissions"
    "--enable-pie"
    "--enable-printing"
    "--enable-pulseaudio"
    "--enable-raw"
    "--enable-readline"
    "--enable-release"
    "--enable-rust"
    "--enable-safe-browsing"
    "--enable-sandbox"
    "--enable-signmar"
    "--enable-skia"
    "--enable-skia-gpu"
    "--enable-startup-notification"
    "--enable-startupcache"
    "--enable-strip"
    # "--enable-system-cairo"  # This is broken during rendering for 40+
    "--enable-system-extension-dirs"
    "--enable-system-ffi"
    "--enable-system-hunspell"
    "--enable-system-pixman"
    "--enable-system-sqlite"
    "--enable-universalchardet"
    "--disable-updater"
    "--enable-url-classifier"
    "--enable-webapp-runtime"
    "--enable-webrtc"
    "--enable-websms-backend"
    "--enable-webspeech"
    "--enable-xul"
    "--enable-zipwriter"
    "--with-pthreads"
    "--with-system-bz2"
    "--with-system-icu"
    "--with-system-jpeg"
    "--with-system-libevent"
    "--with-system-libvpx"
    "--with-system-nspr"
    "--with-system-nss"
    "--with-system-png"
    "--with-system-zlib"
    "--enable-ldap"
    "--enable-mapi"
    "--enable-calendar"
  ];

  postInstall =
    /* GTK3: argv[0] must point to firefox itself */ ''
      wrapProgram "$out/bin/firefox" \
        --argv0 "$out/bin/.firefox-wrapped" \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix XDG_DATA_DIRS : "$out/share" \
        --suffix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    '';

  NIX_CFLAGS_COMPILE = [
    "-fno-lifetime-dse"
    "-fno-schedule-insns2"
    "-fno-delete-null-pointer-checks"
  ];

  passthru = {
    inherit version;

    srcVerification = fetchurl rec {
      failEarly = true;
      sha512Url = "${baseUrl}/SHA512SUMS";
      pgpsigSha512Url = "${sha512Url}.asc";
      pgpKeyFingerprint = "14F2 6682 D091 6CDD 81E3  7B6D 61B7 B526 D98F 0353";
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  #parallelBuild = false;

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
