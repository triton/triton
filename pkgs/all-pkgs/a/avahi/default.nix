{ stdenv
, fetchurl
, gettext
, lib
, intltool
, perl
, xmltoman

, dbus
, expat
, gdbm
, glib
, libdaemon
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt;

  version = "0.7";
in
stdenv.mkDerivation rec {
  name = "avahi-${version}";

  src = fetchurl {
    url = "https://github.com/lathiat/avahi/releases/download/v${version}/${name}.tar.gz";
    sha256 = "57a99b5dfe7fdae794e3d1ee7a62973a368e91e414bd0dfa5d84434de5b14804";
  };

  nativeBuildInputs = [
    gettext
    intltool
    perl
    xmltoman
  ];

  buildInputs = [
    dbus
    expat
    gdbm
    glib
    libdaemon
  ];

  configureFlags = [
    "--sysconfdir=/etc"
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
    "--enable-gdbm"
    "--${boolEn (libdaemon != null)}-libdaemon"
    "--disable-python"
    "--disable-pygobject"
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
    "--disable-tests"
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
    installFlagsArray+=(
      "localstatedir=$TMPDIR"
      "sysconfdir=$out"
      "avahi_runtime_dir=$TMPDIR"
      "DBUS_SYS_DIR=$out/etc/dbus-1/system.d"
    )
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
