{ stdenv
, fetchurl
, makeWrapper

, alsa-lib
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gconf
, gdk-pixbuf
, gdk-pixbuf_unwrapped
, glib
, gtk_2
, gvfs
, libgnome-keyring
, libgpg-error
, libnotify
, nspr
, nss
, pango
, systemd_lib
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
    makeSearchPath;

  version = "1.10.2";
in
stdenv.mkDerivation rec {
  name = "atom-${version}";

  src = fetchurl {
    url = "https://github.com/atom/atom/releases/download/v${version}/"
      + "atom-amd64.deb";
    name = "${name}.deb";
    sha256 = "d7ccccf8b645db9516f66fe5febea2174877067a67e29ca7efcb3a124bae3fde";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gconf
    gdk-pixbuf
    gdk-pixbuf_unwrapped
    glib
    gtk_2
    gvfs
    libgnome-keyring
    libgpg-error
    libnotify
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd_lib
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
    zlib
  ];

  libPath_ = makeSearchPath "lib" buildInputs;
  libPath64 = makeSearchPath "lib64" buildInputs;
  libPath = "${libPath_}:${libPath64}";

  buildCommand = ''
    mkdir -p $out/usr/
    ar p $src data.tar.gz | tar -C $out -xz ./usr
    substituteInPlace $out/usr/share/applications/atom.desktop \
      --replace /usr/share/atom $out/bin
    mv $out/usr/* $out/
    rm -r $out/share/lintian
    rm -r $out/usr/

    wrapProgram $out/bin/atom \
      --prefix "PATH" : "${gvfs}/bin"

    fixupPhase

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$out/share/atom" \
      $out/share/atom/atom
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/share/atom/resources/app/apm/bin/node
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/atom/resources/app.asar.unpacked/node_modules/symbols-view/vendor/ctags-linux
  '';

  dontStrip = true;

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
