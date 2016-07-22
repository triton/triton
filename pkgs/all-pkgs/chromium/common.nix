{ stdenv
, bison
, gperf
, ninja
, perl
, pkgconfig
, python
, pythonPackages
, which
, yasm

, alsa-lib
, atk
, bzip2
, cairo
, cups
, dbus
, dbus-glib
, expat
, flac
, fontconfig
, freetype
, glib
, gtk_2
, kerberos
, libcap
, libevent
, libffi
, libjpeg
, libpng
, libusb
, libwebp
, libxml2
, libxslt
, mesa
, nspr
, nss
, opus
, pango
, pciutils
, protobuf-cpp
, snappy
, speechd
, speex
, systemd_lib
, util-linux_full
, xdg-utils
, xorg

# optional dependencies
, libgcrypt # gnomeSupport || cupsSupport
, libexif # only needed for Chromium before version 51

# package customization
, enableSELinux ? false, libselinux
, enableNaCl ? false
, enableHotwording ? false
, gnomeSupport ? false, gconf
, gnomeKeyringSupport ? false, libgnome-keyring
, proprietaryCodecs ? true
, cupsSupport ? true
, pulseSupport ? true, pulseaudio_lib
, hiDPISupport ? true

, upstream-info
}:

buildFun:

with stdenv.lib;

let
  # The additional attributes for creating derivations based on the chromium
  # source tree.
  extraAttrs = buildFun base;

  mkGypFlags =
    let
      sanitize = value:
        if value == true then
          "1"
        else if value == false then
          "0"
        else
          "${value}";
      toFlag = key: value:
        "-D${key}=${sanitize value}";
    in attrs:
    concatStringsSep " " (attrValues (mapAttrs toFlag attrs));

  # build paths and release info
  packageName = extraAttrs.packageName or extraAttrs.name;
  buildType = "Release";
  buildPath = "out/${buildType}";
  libExecPath = "$out/libexec/${packageName}";

  base = rec {
    name = "${packageName}-${version}";
    inherit (upstream-info) version;
    inherit packageName buildType buildPath;

    src = upstream-info.main;

    unpackCmd = ''
      tar xf "$src" \
        --anchored \
        --no-wildcards-match-slash \
        --exclude='*/tools/gyp'
    '';

    buildInputs = [
      bison
      gperf
      perl
      pkgconfig
      python
      pythonPackages.gyp
      pythonPackages.ply
      pythonPackages.jinja2
      which

      alsa-lib
      atk
      bzip2
      cairo
      dbus
      dbus-glib
      expat
      flac
      freetype
      glib
      gtk_2
      kerberos
      libcap
      libevent
      libffi
      libjpeg
      libpng
      libusb
      libwebp
      libxml2
      libxslt
      mesa
      nspr
      nss
      opus
      pango
      pciutils
      protobuf-cpp
      snappy
      speechd
      speex
      systemd_lib
      util-linux_full
      xdg-utils
      xorg.compositeproto
      xorg.inputproto
      xorg.libX11
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXtst
      xorg.renderproto
      xorg.xextproto
      fontconfig
      xorg.xproto
      xorg.fixesproto
      xorg.damageproto
      yasm
    ] ++ optional gnomeKeyringSupport libgnome-keyring
      ++ optionals gnomeSupport [ gconf libgcrypt ]
      ++ optional enableSELinux libselinux
      ++ optionals cupsSupport [ libgcrypt cups ]
      ++ optional pulseSupport pulseaudio_lib
      ++ optional (versionOlder version "51.0.0.0") libexif;

    patches = [
      ./patches/widevine.patch
      ./patches/nix_plugin_paths_52.patch
    ];

    postPatch = ''
      sed -i -r \
        -e 's/-f(stack-protector)(-all)?/-fno-\1/' \
        -e 's|/bin/echo|echo|' \
        -e "/python_arch/s/: *'[^']*'/: '""'/" \
        build/common.gypi chrome/chrome_tests.gypi

      sed -i -e '/lib_loader.*Load/s!"\(libudev\.so\)!"${systemd_lib}/lib/\1!' \
        device/udev_linux/udev?_loader.cc

      sed -i -e '/libpci_loader.*Load/s!"\(libpci\.so\)!"${pciutils}/lib/\1!' \
        gpu/config/gpu_info_collector_linux.cc

      sed -i -re 's/([^:])\<(isnan *\()/\1std::\2/g' \
        chrome/browser/ui/webui/engagement/site_engagement_ui.cc
    '';

    gypFlags = mkGypFlags ({
      use_system_bzip2 = true;
      use_system_flac = true;
      use_system_libevent = true;
      use_system_libexpat = true;
      use_system_libjpeg = true;
      use_system_libpng = versionOlder upstream-info.version "51.0.0.0";
      use_system_libwebp = true;
      use_system_libxml = true;
      use_system_opus = true;
      use_system_snappy = true;
      use_system_speex = true;
      use_system_stlport = true;
      use_system_xdg_utils = true;
      use_system_yasm = true;
      use_system_zlib = false;
      use_system_protobuf = false; # needs newer protobuf

      use_system_harfbuzz = false;
      use_system_icu = false; # Doesn't support ICU 52 yet.
      use_system_libusb = false; # http://crbug.com/266149
      use_system_skia = false;
      use_system_sqlite = false; # http://crbug.com/22208
      use_system_v8 = false;

      linux_use_bundled_binutils = false;
      linux_use_bundled_gold = false;
      linux_use_gold_flags = true;

      proprietary_codecs = proprietaryCodecs;
      enable_hangout_services_extension = proprietaryCodecs;
      use_sysroot = false;
      use_gnome_keyring = gnomeKeyringSupport;
      use_gconf = gnomeSupport;
      use_gio = gnomeSupport;
      use_pulseaudio = pulseSupport;
      linux_link_pulseaudio = pulseSupport;
      disable_nacl = !enableNaCl;
      enable_hotwording = enableHotwording;
      selinux = enableSELinux;
      use_cups = cupsSupport;

      werror = "";
      clang = false;
      enable_hidpi = hiDPISupport;

      # Don't build debug symbols
      fastbuild = true;
      remove_webcore_debug_symbols = true;

      # Google API keys, see:
      #   http://www.chromium.org/developers/how-tos/api-keys
      # Note: These are for NixOS/nixpkgs use ONLY. For your own distribution,
      # please get your own set of keys.
      google_api_key = "AIzaSyDGi15Zwl11UNe6Y-5XW_upsfyw31qwZPI";
      google_default_client_id = "404761575300.apps.googleusercontent.com";
      google_default_client_secret = "9rIFQjfnkykEmqb6FfjJQD1D";
    } // optionalAttrs proprietaryCodecs {
      # enable support for the H.264 codec
      ffmpeg_branding = "Chrome";
    } // optionalAttrs (stdenv.system == "x86_64-linux") {
      target_arch = "x64";
      python_arch = "x86-64";
    } // optionalAttrs (stdenv.system == "i686-linux") {
      target_arch = "ia32";
      python_arch = "ia32";
    } // (extraAttrs.gypFlags or {}));

    configurePhase = ''
      echo "Precompiling .py files to prevent race conditions..." >&2
      python -m compileall -q -f . > /dev/null 2>&1 || : # ignore errors

      # This is to ensure expansion of $out.
      libExecPath="${libExecPath}"
      python build/linux/unbundle/replace_gyp_files.py ${gypFlags}
      python build/gyp_chromium -f ninja --depth . ${gypFlags}
    '';

    # TODO: remove this flag, it should be fixed in 53+?
    CXXFLAGS = "-fno-delete-null-pointer-checks";

    buildPhase = let
      buildCommand = target: ''
        "${ninja}/bin/ninja" -C "${buildPath}"  \
          -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES \
          "${target}"
      '' + optionalString (target == "mksnapshot" || target == "chrome") ''
        paxmark m "${buildPath}/${target}"
      '';
      targets = extraAttrs.buildTargets or [];
      commands = map buildCommand targets;
    in concatStringsSep "\n" commands;
  };

# Remove some extraAttrs we supplied to the base attributes already.
in stdenv.mkDerivation (base // removeAttrs extraAttrs [
  "name" "gypFlags" "buildTargets"
])
