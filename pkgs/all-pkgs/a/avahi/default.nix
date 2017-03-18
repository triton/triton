{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
, gettext
, xmltoman
, intltool

, dbus
, expat
, glib
, libdaemon
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt;

  version = "0.6.32";
in
stdenv.mkDerivation rec {
  name = "avahi-${version}";

  src = fetchurl {
    url = "https://github.com/lathiat/avahi/archive/v${version}.tar.gz";
    name = "${name}.tar.gz";
    sha256 = "0vi2f48d3jhkads02zrvvn27li2kxnrky5rla380qvr4g3c97dky";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    gettext
    xmltoman
    intltool
  ];

  buildInputs = [
    dbus
    expat
    glib
    libdaemon
  ];

  postPatch = ''
    patchShebangs .
  '';

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--enable-nls"
    "--${boolEn (glib != null)}-glib"
    "--${boolEn (glib != null)}-gobject"
    # Disable all builtin interfaces
    "--disable-qt3"
    "--disable-qt4"
    "--disable-gtk"
    "--disable-gtk3"
    "--${boolEn (dbus != null)}-dbus"
    "--disable-dbm"
    "--disable-gdbm"
    "--${boolEn (libdaemon != null)}-libdaemon"
    "--disable-python"
    # Circular dependency:
    # avahi -> pygtk -> gtk2 -> cups -> avahi
    "--disable-pygtk"
    "--disable-python-dbus"
    "--disable-mono"
    "--disable-monodoc"
    "--enable-autoipd"
    "--disable-doxygen-doc"
    "--disable-doxygen-dot"
    "--disable-doxygen-man"
    "--disable-doxygen-rtf"
    "--disable-doxygen-xml"
    "--disable-doxygen-chm"
    "--disable-doxygen-chi"
    "--disable-doxygen-html"
    "--disable-doxygen-ps"
    "--disable-doxygen-pdf"
    "--disable-core-docs"
    "--enable-manpages"
    "--enable-xmltoman"
    "--enable-tests"
    "--enable-compat-libdns_sd"
    "--enable-compat-howl"
    "--with-distro=none"
    "--${boolWt (expat != null)}-xml${boolString (expat != null) "=expat" ""}"
    #"--with-avahi-group=<user>"
    #"--with-avahi-group=<group>"
    #"--with-autoipd-user=<user>"
    #"--with-autoipd-group=<group>"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
  ];

  preInstall = ''
    installFlagsArray+=("localstatedir=$TMPDIR")
  '';

  postInstall =
    /* Maintain compat for mdnsresponder and howl */ ''
      ln -sv avahi-compat-libdns_sd/dns_sd.h $out/include/dns_sd.h
      ln -sv avahi-compat-howl $out/include/howl
      ln -sv avahi-compat-howl.pc $out/lib/pkgconfig/howl.pc
    '';

  meta = with lib; {
    description = "Facilitates service discovery on a local network";
    homepage = http://avahi.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
