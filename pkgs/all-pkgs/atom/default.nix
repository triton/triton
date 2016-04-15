{ stdenv
, fetchurl
, buildEnv
, makeWrapper

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
, gdk-pixbuf-core
, glib
, gtk2
, gvfs
, libcap
, libgnome-keyring
, libgpg-error
, libnotify
, libpng
, nspr
, nss
, pango
, xorg
, systemd_lib
, zlib
}:

let
  inherit (stdenv.lib)
    makeLibraryPath;
in

stdenv.mkDerivation rec {
  name = "atom-${version}";
  version = "1.6.2";

  src = fetchurl {
    url = "https://github.com/atom/atom/releases/download/v${version}/atom-amd64.deb";
    sha256 = "36b1a5ff2fe30e82eed351ed610e58a8e601785494f3321f2596a9aa01bb82ce";
    name = "${name}.deb";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  atomLibs = makeLibraryPath [
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
    gdk-pixbuf-core
    glib
    gtk2
    libcap
    libgnome-keyring
    libgpg-error
    libnotify
    libpng
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXdmcp
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.xcbutil
    stdenv.cc.cc
    systemd_lib
    zlib
  ];

  unpackPhase = "true";

  doConfigure = false;

  doBuild = false;

  installPhase = ''
    mkdir -pv $out

    ar p $src data.tar.gz | tar -C $out -xz
    mv -v $out/usr/* $out/
    rm -rv $out/usr/

    sed -i $out/share/applications/atom.desktop \
      -e 's,/usr/share/atom,$out/share/atom,'

    rm -rv $out/share/lintian
  '';

  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$out/share/atom:${atomLibs}" \
      $out/share/atom/atom

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$out/share/atom:${atomLibs}" \
      $out/share/atom/resources/app/apm/bin/node

    wrapProgram $out/share/atom/atom \
      --prefix "LD_LIBRARY_PATH" : "${atomLibs}" \
      --prefix "PATH" : "${gvfs}/bin"

    wrapProgram $out/bin/apm \
      --prefix "LD_LIBRARY_PATH" : "${atomLibs}"
  '';

  meta = with stdenv.lib; {
    description = "A hackable text editor for the 21st Century";
    homepage = https://atom.io/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
