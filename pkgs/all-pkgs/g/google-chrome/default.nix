{ stdenv
, fetchurl
, lib
, makeWrapper
, patchelf

, adobe-flash-player
, adwaita-icon-theme
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gsettings-desktop-schemas
, gtk_3
, libcap
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, nspr
, nss
, pango
, shared-mime-info
, systemd_lib
, util-linux_lib
, xdg-utils

, flash ? false

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    bool01
    boolString
    elem
    makeSearchPath
    optionals
    platforms;

  chromiumChannel =
    if channel == "unstable" then
      "dev"
    else
      channel;

  source = (import ./sources.nix { })."${channel}";
  version = (import ../../c/chromium/sources.nix { })."${chromiumChannel}".version;

  arch =
    if elem targetSystem platforms.x86_64 then
      "amd64"
    else
      throw "Architecture not supported by google-chrome: `${targetSystem}`";

  channame = "${boolString (channel != "stable") "-${channel}" ""}";
in
stdenv.mkDerivation rec {
  name = "google-chrome-${channel}-${version}";

  src = fetchurl {
    url = "https://dl.google.com/linux/chrome/deb/pool/main/g/"
      + "google-chrome-${channel}/"
      + "google-chrome-${channel}_${version}-1_${arch}.deb";
    hashOutput = false;
    inherit (source."${targetSystem}") sha256;
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  buildInputs = [
    adwaita-icon-theme
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk_3
    libcap
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    nspr
    nss
    pango
    stdenv.cc.cc
    stdenv.cc.libc
    systemd_lib
    util-linux_lib
    xdg-utils
  ] ++ optionals flash [
    adobe-flash-player
  ];

  chromeBinPath = makeSearchPath "bin" buildInputs;
  chromeLibPath = makeSearchPath "lib" buildInputs;

  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -pv $out/{bin,share}

    cp -av opt/* $out/share
    cp -av usr/share/* $out/share


    for icon in $out/share/google/chrome*/product_logo_*[0-9].png; do
      num_and_suffix="''${icon##*logo_}"
      icon_size="''${num_and_suffix%.*}"
      logo_output_prefix="$out/share/icons/hicolor"
      logo_output_path="$logo_output_prefix/''${icon_size}x''${icon_size}/apps"
      mkdir -p "$logo_output_path"
      mv "$icon" "$logo_output_path/google-chrome${channame}.png"
    done
  '';

  preFixup = ''
    sed -i "$out/share/applications/google-chrome${channame}.desktop" \
      -e "s,/usr/bin/google-chrome-${channel},$out/bin/google-chrome-${channel},"
    sed -i "$out/share/gnome-control-center/default-apps/google-chrome${channame}.xml" \
      -e "s,/opt/google/chrom${channame}/google-chrome${channame},$out/bin/google-chrome${channame},"
    sed -i "$out/share/menu/google-chrome${channame}.menu" \
      -e "s,/opt,$out/share," \
      -e "s,$out/share/google/chrome/google-chrome${channame},$out/bin/google-chrome${channame},"

    pushd "$out/share/google/chrome${channame}/"
      local -a patch_exes=(
        'chrome'
        'chrome-sandbox'
        'nacl_helper'
      )
      for elfExecutable in "''${patch_exes[@]}"; do
        echo "patching: $elfExecutable"
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$chromeLibPath" \
          "$elfExecutable"
      done

      # local -a patch_libs=(
      #   'libwidevinecdm.so'
      #   'libwidevinecdmadapter.so'
      # )
      # for elfLibraries in "''${patch_libs[@]}"a; do
      #   echo "patching: $elfLibraries"
      #   patchelf \
      #     --set-rpath "$chromeLibPath" \
      #     "$elfLibraries"
      # done
    popd

    ln -sv \
      "$out/share/google/chrome${channame}/google-chrome${channame}" \
      "$out/bin/google-chrome${channame}"

    wrapProgram "$out/bin/google-chrome${channame}" \
      --set 'FONTCONFIG_PATH' '${fontconfig}/etc/fonts' \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix LD_LIBRARY_PATH : "${chromeLibPath}" \
      --prefix PATH : "${chromeBinPath}" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with lib; {
    description = "The web browser from Google";
    homepage = https://www.google.com/chrome/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
