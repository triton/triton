{ stdenv
, fetchTritonPatch
, fetchurl

, atk
, dbus_glib
, gdk-pixbuf
, glib
, gobject-introspection
, gtk2
, pango
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

assert xorg != null -> xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "libunique-${version}";
  versionMajor = "1.1";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libunique/${versionMajor}/${name}.tar.bz2";
    sha256 = "1fsgvmncd9caw552lyfg8swmsd6bh4ijjsph69bwacwfxwf09j75";
  };

  patches = [
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "libunique/libunique-1.1.6-include-terminator.patch";
      sha256 = "32ade6dbddac23e3ff181d14bc1e59e6dbff14f9a7c0ac0afc0a657850714d4d";
    })
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "libunique/libunique-1.1.6-G_CONST_RETURN.patch";
      sha256 = "69cce7257d144e9a6ed9f402196d79ff52013d710e40101f8ef20481876692b2";
    })
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "libunique/libunique-1.1.6-fix-test.patch";
      sha256 = "1e9fcc4189fb4080c6eae1dd97a68a9dc46f8e1a71be1a348ed6c39f9f02f67e";
    })
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "libunique/libunique-1.1.6-compiler-warnings.patch";
      sha256 = "1365451d30af820ba14b54ab27becdbba4cec3ade29e63e2cdecdc23d404bfc6";
    })
  ];

  buildInputs = [
    atk
    dbus_glib
    gdk-pixbuf
    glib
    gobject-introspection
    gtk2
    pango
    xorg.libX11
  ];

  configureFlags = [
    (enFlag "dbus" (dbus_glib != null) null)
    "--enable-bacon"
    "--disable-maintainer-flags"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    (wtFlag "x" (xorg != null) null)
  ];

  postPatch =
  /* don't make deprecated usages hard errors */ ''
    substituteInPlace unique/dbus/Makefile \
      --replace '-Werror' ""
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A library for writing single instance applications";
    homepage = http://live.gnome.org/LibUnique;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms; [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
