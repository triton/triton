{ stdenv
, autoconf
, autoconf-archive
, automake
, fetchurl
, intltool
, libtool
, lib
, makeWrapper
, python2

, dbus
, dbus-glib
, enchant
, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk2
, iso-codes
, libcanberra
, libnotify
, libproxy
, libxml2
, openssl
, pciutils
, shared-mime-info
}:

stdenv.mkDerivation rec {
  name = "hexchat-2.12.4";

  src = fetchurl {
    url = "https://dl.hexchat.net/hexchat/${name}.tar.xz";
    hashOutput = false;
    sha256 = "fa35913158bbc7d0d99de79371b6df3e8d21802f1d2c7c92f0e5db694acf2c3a";
  };

  nativeBuildInputs = [
    # Someone really bungled building the release tarball so we have to re-autotoolsify
    autoconf
    autoconf-archive
    automake
    libtool

    intltool
    libxml2
    makeWrapper
    python2
  ];

  buildInputs = [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gnome-themes-standard
    gtk2
    iso-codes
    libcanberra
    libnotify
    libproxy
    openssl
    pciutils
  ];

  postPatch = ''
    links="$(find . -type l)"
    for link in $links; do
      readlink -f "$link" || rm "$link"
    done

    grep 'libenchant.so.1' src/fe-gtk/sexy-spell-entry.c
    sed -i src/fe-gtk/sexy-spell-entry.c \
      -e "s,libenchant.so.1,${enchant}/lib/libenchant.so.1,g"
  '';

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = [
    "--enable-openssl"
    "--enable-gtkfe"
    "--enable-textfe"
    "--enable-python=python2"
    "--disable-perl"
    "--disable-lua"
  ];

  preBuild = ''
    export GDK_PIXBUF_MODULE_FILE='${gdk-pixbuf.loaders.cache}'
    export XDG_DATA_DIRS='${shared-mime-info}/share'
  '';

  preFixup = ''
    wrapProgram $out/bin/hexchat \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "108B F221 2A05 1F4A 72B1  8448 B3C7 CE21 0DE7 6DFC";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "A popular and easy to use graphical IRC (chat) client";
    homepage = http://hexchat.github.io/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
