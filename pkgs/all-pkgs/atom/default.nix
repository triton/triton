{ stdenv
, fetchurl
, buildEnv
, makeWrapper

, alsaLib
, atk
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
, libgpgerror
, nspr
, nss
, pango
, xorg
, systemd
, zlib
}:

let
  atomEnv = buildEnv {
    name = "env-atom";
    paths = [
      alsaLib
      atk
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
      libgpgerror
      nspr
      nss
      pango
      xorg.libX11
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      stdenv.cc.cc
      systemd
      zlib
    ];
  };
in

stdenv.mkDerivation rec {
  name = "atom-${version}";
  version = "1.4.3";

  src = fetchurl {
    url = "https://github.com/atom/atom/releases/download/v${version}/atom-amd64.deb";
    sha256 = "15ix5ww3ny5ylgmmxpkc32li6af2vc4a2p6aymx9c472fra0c41x";
    name = "${name}.deb";
  };

  phases = [
    "installPhase"
    "fixupPhase"
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    atomEnv
    gvfs
  ];

  installPhase = ''
    mkdir -pv $out

    ar p $src data.tar.gz | tar -C $out -xz ./usr

    substituteInPlace $out/usr/share/applications/atom.desktop \
      --replace /usr/share/atom $out/bin

    mv -v $out/usr/* $out/
    rm -rv $out/share/lintian
    rm -rv $out/usr/

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/atom/atom
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/atom/resources/app/apm/bin/node

    wrapProgram $out/bin/atom \
      --prefix "LD_LIBRARY_PATH" : "${atomEnv}/lib:${atomEnv}/lib64" \
      --prefix "PATH" : "${gvfs}/bin"
    wrapProgram $out/bin/apm \
      --prefix "LD_LIBRARY_PATH" : "${atomEnv}/lib:${atomEnv}/lib64"
  '';

  meta = with stdenv.lib; {
    description = "A hackable text editor for the 21st Century";
    homepage = https://atom.io/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
