{ stdenv
, fetchTritonPatch
, fetchurl
, intltool

, dbus_glib
, gnome2
, glib
, gobject-introspection
, gtk3
, libxml2
, polkit
, openldap
#, orbit
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gconf-${version}";
  versionMajor = "3.2";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/GConf/${versionMajor}/GConf-${version}.tar.xz";
    sha256 = "0k3q9nh53yhc9qxf1zaicz4sk8p3kzq4ndjdsgpaa2db0ccbj4hr";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    dbus_glib
    glib
    gobject-introspection
    gtk3
    libxml2
    openldap
    gnome2.ORBit2
    #orbit
    polkit
  ];

  patches = [
    # Do not start gconfd when installing schemas
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gconf/gconf-2.24.0-no-gconfd.patch";
      sha256 = "f8352648276d2a2dab162ddade55ec0371e7c4f8bc3834de246fda8c32c66d3c";
    })
    # Do not crash in gconf_entry_set_value() when entry pointer is NULL
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gconf/gconf-2.28.0-entry-set-value-sigsegv.patch";
      sha256 = "e58c0981491e794de05dd71562e0a9675433469e87c7149088ebea432c9619b0";
    })
    # gsettings-data-convert: Warn (and fix) invalid schema paths
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gconf/gconf-3.2.6-gsettings-data-convert-paths.patch";
      sha256 = "836d5259ae84832004447defc2f0cea15ca1d8fffec6b8bf5d7eabb4d090070d";
    })
    # mconvert: enable recursive scheme lookup and fix a crasher
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gconf/gconf-3.2.6-mconvert-crasher.patch";
      sha256 = "22ada6a8e7c26b1c89df8c79a9a46fd3a43b35b9e96657e328ccd6f376f7034e";
    })
    # dbus: Don't spew to console when unable to connect to dbus daemon
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gconf/gconf-3.2.6-spew-console-error.patch";
      sha256 = "3638009b19744bd301364e110da70f8013fa41a68e4367f7eefae4b8fd7a05c7";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-documentation"
    "--enable-gtk"
    (enFlag "orbit" (gnome2.ORBit2 != null) null)
    (enFlag "defaults-service" (dbus_glib != null) null)
    "--enable-gsettings-backend"
    "--enable-nls"
    (enFlag "introspection" (gobject-introspection != null) null)
    (wtFlag "gtk" (gtk3 != null) "3.0")
    (wtFlag "openldap" (openldap != null) null)
  ];

  meta = with stdenv.lib; {
    description = "GNOME configuration system and daemon";
    homepage = http://projects.gnome.org/gconf/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
