{ stdenv
, fetchurl
, lib
, makeWrapper
, patchelf

, alsa-lib
, atk
, bzip2
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gconf
, gdk-pixbuf_unwrapped
, glib
, gtk_2
, libcap
, nspr
, nss
, pango
, systemd_lib
, xdg-utils
, xorg

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
    platforms;

  source = (import ./sources.nix { })."${channel}";
  version = (import ../../c/chromium/sources.nix { })."${channel}".version;

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
    alsa-lib
    atk
    bzip2
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gconf
    gdk-pixbuf_unwrapped
    glib
    gtk_2
    libcap
    nspr
    nss
    pango
    stdenv.cc.cc
    stdenv.libc
    systemd_lib
    xdg-utils
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


    for elf in $out/share/google/chrome${channame}/{chrome,chrome-sandbox,nacl_helper} ; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$chromeLibPath" \
        "$elf"
    done

    ln -sv \
      "$out/share/google/chrome${channame}/google-chrome${channame}" \
      "$out/bin/google-chrome${channame}"

    wrapProgram "$out/bin/google-chrome${channame}" \
      --prefix LD_LIBRARY_PATH : "${chromeLibPath}" \
      --prefix PATH : "${chromeBinPath}"
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
