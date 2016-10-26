{ stdenv
, fetchurl
, intltool
, python2

, dbus
, dbus-glib
, enchant
, gdk-pixbuf
, glib
, gtk2
, iso-codes
, libcanberra
, libnotify
, libproxy
, libxml2
, openssl
, pciutils
}:

stdenv.mkDerivation rec {
  name = "hexchat-2.12.3";

  src = fetchurl {
    url = "https://dl.hexchat.net/hexchat/${name}.tar.xz";
    hashOutput = false;
    sha256 = "6f2b22372c7a9ed8ffab817079638e8f4178f5f8ba63c89cb3baa01be614f2ba";
  };

  postPatch = ''
    grep 'libenchant.so.1' src/fe-gtk/sexy-spell-entry.c
    sed -i "s,libenchant.so.1,${enchant}/lib/libenchant.so.1,g" src/fe-gtk/sexy-spell-entry.c
  '';

  nativeBuildInputs = [
    intltool
    libxml2
    python2
  ];

  buildInputs = [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk2
    iso-codes
    libcanberra
    libnotify
    libproxy
    openssl
    pciutils
  ];

  configureFlags = [
    "--enable-openssl"
    "--enable-gtkfe"
    "--enable-textfe"
    "--enable-python=python2"
    "--disable-perl"
    "--disable-lua"
    "--enable-shm"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "108B F221 2A05 1F4A 72B1  8448 B3C7 CE21 0DE7 6DFC";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
