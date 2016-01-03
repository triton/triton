{ stdenv
, fetchurl
, gettext
, intltool
, pkgconfig

, dbus
, expat
, glib
, libdaemon

# Remove this flag
, withLibdnssdCompat ? true
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "avahi-0.6.31";

  src = fetchurl {
    url = "http://avahi.org/download/${name}.tar.gz";
    sha256 = "0j5b5ld6bjyh3qhd2nw0jb84znq0wqai7fsrdzg7bpg24jdp2wl3";
  };

  patches = [
    ./no-mkdir-localstatedir.patch
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--enable-nls"
    (enFlag "glib" (glib != null) null)
    (enFlag "gobject" (glib != null) null)
    # Disable all builtin interfaces
    "--disable-qt3"
    "--disable-qt4"
    "--disable-gtk"
    "--disable-gtk3"
    (enFlag "dbus" (dbus != null) null)
    "--disable-dbm"
    "--disable-gdbm"
    (enFlag "libdaemon" (libdaemon != null) null)
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
    (wtFlag "xml" (expat != null) "expat")
    #"--with-avahi-group=<user>"
    #"--with-avahi-group=<group>"
    #"--with-autoipd-user=<user>"
    #"--with-autoipd-group=<group>"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus
    expat
    glib
    libdaemon
  ];

  postInstall = ''
    # Maintain compat for mdnsresponder and howl
    ln -s avahi-compat-libdns_sd/dns_sd.h $out/include/dns_sd.h
    ln -s avahi-compat-howl $out/include/howl
    ln -s avahi-compat-howl.pc $out/lib/pkgconfig/howl.pc
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Facilitates service discovery on a local network";
    homepage = http://avahi.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}