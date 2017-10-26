{ stdenv
, fetchurl
, intltool
, lib
, python2

, atk
, cairo
, gdk-pixbuf
, glib
, gnome-common
, gobject-introspection
, gtk_3
, libx11
, libstartup_notification
, libxres
, pango
}:

let
  channel = "3.24";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "libwnck-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libwnck/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "afa6dc283582ffec15c3374790bcbcb5fb422bd38356d72deeef35bf7f9a1f04";
  };

  nativeBuildInputs = [
    intltool
    python2
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gnome-common
    gobject-introspection
    gtk_3
    libx11
    libstartup_notification
    libxres
    pango
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libwnck/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Window Navigator Construction Kit";
    homepage = https://developer.gnome.org/libwnck/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
