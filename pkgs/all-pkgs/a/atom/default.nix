{ stdenv
, fetchurl
, lib
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
, git
, glib
, gtk_2
, gvfs
, kbproto
, libcap
, libgnome-keyring
, libgpg-error
, libnotify
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
, nspr
, nss
, pango
, python
, shared-mime-info
, systemd_lib
, xorg
, xproto
, zlib

, channel
}:

let
  inherit (lib)
    makeSearchPath;

  sources = {
    "stable" = {
      suffix = "";
      version = "1.21.1";
      sha256 = "d672ad700b6d26308a0c30e62cd952f9b4e72635232a6a70fa5d3fb6f990b78e";
    };
    "beta" = {
      suffix = "-beta";
      version = "1.22.0-beta1";
      sha256 = "6d5c4274852828a6826fb07a0065ea7b67107e584ef0bf1fc77f5a062490ef61";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "atom${source.suffix}-${source.version}";

  src = fetchurl {
    url = "https://github.com/atom/atom/releases/download/v${source.version}/"
      + "atom-amd64.deb";
    name = "${name}.deb";
    inherit (source) sha256;
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
    kbproto
    libcap
    libgnome-keyring
    libgpg-error
    libnotify
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    xorg.libxkbfile
    libxrandr
    libxrender
    libxscrnsaver
    xorg.libXtst
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd_lib
    xproto
    zlib
  ];

  libPath_ = makeSearchPath "lib" buildInputs;
  libPath64 = makeSearchPath "lib64" buildInputs;
  libPath = "${libPath_}:${libPath64}";

  unpackPhase = ''
    mkdir -pv "$out"
    ar p $src data.tar.xz | tar -xJ
  '';

  installPhase = ''
    rm -rv usr/share/lintian
    mv -v usr/* $out/
  '';

  preFixup = ''
    sed -i $out/share/applications/atom${source.suffix}.desktop \
      -e "s,/usr/share/atom${source.suffix},$out/bin,"

    # Replace vendored git binary
    atom_git=$out/share/atom${source.suffix}/resources/app${if channel == "beta" then ".asar.unpacked" else ""}/node_modules/dugite/git
    rm -fv $atom_git/bin/git
    ln -sv ${git}/bin/git \
      $atom_git/bin/git
    for gitcommand in ${git}/libexec/git-core/*; do
      if [ -e "$atom_git/libexec/git-core/$(basename "$gitcommand")" ] && \
         [ ! -d "$atom_git/libexec/git-core/$(basename "$gitcommand")" ]; then
        rm -v "$atom_git/libexec/git-core/$(basename "$gitcommand")"
        ln -sv "$gitcommand" \
          "$atom_git/libexec/git-core/$(basename "$gitcommand")"
      fi
    done

    # Fix beta detection
    sed -i $out/bin/atom${source.suffix} \
      -e 's,$(basename $0),atom${source.suffix},'

    wrapProgram $out/bin/atom${source.suffix} \
      --prefix 'CPATH' : "${makeSearchPath "include" buildInputs}" \
      --prefix 'PATH' : "${gvfs}/bin:${python}/bin" \
      --prefix 'LIBRARY_PATH' : "${libPath}" \
      --prefix 'LD_LIBRARY_PATH' : "${libPath}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"

    wrapProgram $out/bin/apm${source.suffix} \
      --prefix 'CPATH' : "${makeSearchPath "include" buildInputs}" \
      --prefix 'PATH' : "${gvfs}/bin:${python}/bin" \
      --prefix 'LIBRARY_PATH' : "${libPath}" \
      --prefix 'LD_LIBRARY_PATH' : "${libPath}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$out/share/atom${source.suffix}" \
      $out/share/atom${source.suffix}/atom
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/share/atom${source.suffix}/resources/app/apm/bin/node
    #find $out/share/atom${source.suffix} \
    #  -name "*.node" \
    #  -exec patchelf --set-rpath "${libPath}:$out/share/atom${source.suffix}" {} \;
  '';

  buildDirCheck = false;  # slow
  dontStrip = true;

  meta = with lib; {
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
