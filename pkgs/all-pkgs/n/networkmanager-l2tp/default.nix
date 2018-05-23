{ stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchTritonPatch
, gettext
, intltool
, lib
, libtool

, dbus-glib
, glib
, gtk3
, libgnome-keyring
, networkmanager
, ppp
, strongswan
, xl2tpd
}:

let
  version = "0.9.8.7";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-l2tp-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "seriyps";
    repo = "NetworkManager-l2tp";
    rev = version;
    sha256 = "d844cc391189783ebb08907940b51ab1550b34315460df97ac95b10d69f69a5a";
  };

  nativeBuildInputs = [
    automake
    autoconf
    gettext
    intltool
    libtool
  ];

  buildInputs = [
    dbus-glib
    glib
    gtk3
    libgnome-keyring
    networkmanager
    ppp
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/l2tp-purity.patch";
      sha256 = "e170efd7f3d96c61898a79569b570c435d8503a9ae021ed820feba1c82cb4089";
    })
  ];

  preConfigure = /* upstrem autogen.sh enables maintainer mode */ ''
    autoreconf --install --symlink
    intltoolize --force
    autoreconf
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-more-warnings"
    #"--with-pppd-plugin-dir"
    "--with-gnome"
  ];

  postConfigure = ''
    sed -i Makefile */Makefile \
      -e 's/-Werror//g'
  '';

  meta = with lib; {
    description = "L2TP plugin for NetworkManager";
    homepage = https://github.com/seriyps/NetworkManager-l2tp;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
